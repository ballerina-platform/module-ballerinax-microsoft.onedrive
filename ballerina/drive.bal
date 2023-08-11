// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;

isolated function getDriveItemArray(http:Client httpClient, string url) returns @tainted DriveItemData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        io:println(handledResponse);
        json responseArray = check handledResponse.value;
        return check convertToDriveItemArray(<json[]>responseArray);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function getDriveItem(http:Client httpClient, string url) returns @tainted DriveItemData|Error {
    http:Response response = check httpClient->get(url);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        io:println(handledResponse);

        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function createFolder(http:Client httpClient, string url, FolderMetadata metaData) returns 
                               @tainted DriveItemData|Error {
    json payload = check metaData.cloneWithType(json);
    _ = check payload.mergeJson({"@microsoft.graph.conflictBehavior": metaData?.conflictResolutionBehaviour});
    http:Response response = check httpClient->post(url, payload);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }   
}

isolated function updateDriveItem(http:Client httpClient, string url, DriveItem replacementData) returns 
                                  @tainted DriveItemData|Error {
    json payload = check replacementData.cloneWithType(json);
    http:Response response = check httpClient->patch(url, payload);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    } 
}

isolated function downloadDriveItem(http:Client httpClient, string url) returns @tainted File|Error {
    http:Response response = check httpClient->get(<@untainted>url);
    if response.statusCode is http:REDIRECT_FOUND_302 {
        return check handleDownloadRedirected(check response.getHeader(http:LOCATION));
    } else {
        json errorPayload = check response.getJsonPayload();
        string message = errorPayload.toString(); 
        return error PayloadValidationError(message);
    }
}

isolated function handleDownloadRedirected(string webUrl) returns File|Error {
    http:Client downloadClient = check new (webUrl, {
        httpVersion: http:HTTP_1_1,
        http1Settings: {
            chunking: http:CHUNKING_NEVER
        }
    });
    http:Response response = check downloadClient->get(EMPTY_STRING);
    if (response.statusCode is http:STATUS_OK) {
        byte[] content = check response.getBinaryPayload();
        return {
            content: content,
            mimeType: response.getContentType()
        }; 
    } else {
        json errorPayload = check response.getJsonPayload();
        string message = errorPayload.toString(); 
        return error PayloadValidationError(message);
    }
}

isolated function handleDownloadPrtialItem(string webUrl, map<string> headerMap) returns @tainted File|Error {
    http:Client downloadClient = check new (webUrl, {
        httpVersion: http:HTTP_1_1,
        http1Settings: {
            chunking: http:CHUNKING_NEVER
        }
    });
    http:Response response = check downloadClient->get(EMPTY_STRING, headerMap);
    if (response.statusCode is http:STATUS_OK|http:STATUS_PARTIAL_CONTENT) {
        byte[] content = check response.getBinaryPayload();
        return {
            content: content,
            mimeType: response.getContentType()
        }; 
    } else {
        json errorPayload = check response.getJsonPayload();
        string message = errorPayload.toString(); 
        return error PayloadValidationError(message);
    }
}

isolated function uploadDriveItem(http:Client httpClient, string url, stream<byte[],io:Error?> binaryStream, 
                                  string mediaType) returns @tainted DriveItemData|Error {
    http:Request request = new;
    request.setByteStream(binaryStream, mediaType);
    http:Response response = check httpClient->put(url, request);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    } 
}

//************************ Functions for uploading and replacing the files using byte[] ****************************
isolated function uploadDriveItemByteArray(http:Client httpClient, string url, byte[] byteArray, string mediaType) 
                                           returns @tainted DriveItemData|Error {
    http:Request request = new;
    request.setBinaryPayload(byteArray, mediaType);
    http:Response response = check httpClient->put(url, request);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    } 
}
//******************************************************************************************************************

isolated function uploadBytes(int fileSize, byte[] block, int startByte, int endByte, string uploadUrl) returns 
                              @tainted map<json>|Error {
    http:Client uploadClient = check new(uploadUrl, {
        httpVersion: http:HTTP_1_1,
        timeout: REQUEST_TIMEOUT,
        http1Settings: {chunking: http:CHUNKING_NEVER},
        retryConfig : {
            count: RETRY_ATTEMPTS,
            interval: RETRY_INTERVAL,
            backOffFactor: BACKOFF_FACTOR,
            maxWaitInterval: MAX_WAIT,
            statusCodes: [http:STATUS_BAD_GATEWAY, http:STATUS_SERVICE_UNAVAILABLE, http:STATUS_GATEWAY_TIMEOUT, 
                http:STATUS_HTTP_VERSION_NOT_SUPPORTED, http:STATUS_INTERNAL_SERVER_ERROR]
        }
    });
    http:Request request = new;
    string contentRangeHeader = string `bytes ${startByte.toString()}-${endByte.toString()}/${fileSize.toString()}`;
    map<string> headers = {
        [CONTENT_RANGE]: contentRangeHeader,
        [http:CONTENT_LENGTH]: block.length().toString()
    };
    setSpecficRequestHeaders(request, headers);
    request.setBinaryPayload(block);
    http:Response response = check uploadClient->put(EMPTY_STRING, request);
    map<json>|string? handledResponse = check handleResumableUploadResponse(response, uploadUrl);
    if (handledResponse is map<json>) {
        return handledResponse;
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function handleResumableUploadResponse(http:Response httpResponse, string uploadUrl) returns 
                                                @tainted map<json>|Error? {
    if (httpResponse.statusCode is http:STATUS_OK|http:STATUS_CREATED|http:STATUS_ACCEPTED) {
        json jsonResponse = check httpResponse.getJsonPayload();
        return <map<json>>jsonResponse;
    } else if (httpResponse.statusCode is http:STATUS_NOT_FOUND) {

    }
    json errorPayload = check httpResponse.getJsonPayload();
    string message = errorPayload.toString();
    return error PayloadValidationError(message);
}

# Sets required request headers.
# 
# + request - Request object reference
# + specificRequiredHeaders - Request headers as a key value map
isolated function setSpecficRequestHeaders(http:Request request, map<string> specificRequiredHeaders) {
    string[] keys = specificRequiredHeaders.keys();
    foreach string keyItem in keys {
        request.setHeader(keyItem, specificRequiredHeaders.get(keyItem));
    }
}

isolated function getSharableLink(http:Client httpClient, string url, PermissionOptions options) returns 
                                  @tainted Permission|Error {
    json permissionOptions = check options.cloneWithType(json);
    return check httpClient->post(url, permissionOptions, targetType = Permission);
}

isolated function sendSharableLink(http:Client httpClient, string url, ItemShareInvitation invitation) returns 
                                   @tainted Permission|Error {
    boolean isValid = let var message = invitation?.message in message is string ? message.length() >= MAX_CHAR_COUNT ? 
        false : true : true; 
    if (!isValid) {
        return error PayloadValidationError(INVALID_MESSAGE);
    }              
    json shareInvitation = check invitation.cloneWithType(json);
    return check httpClient->post(url, shareInvitation, targetType = Permission);
}

isolated function copyDriveItem(http:Client httpClient, string url, ParentReference? parentReference, string? name) 
                                returns @tainted string|Error {
    json copyItemOptions = {};
    if ((name is () || name == "") &&  parentReference is ()) {
        copyItemOptions = {};
    } else if (parentReference is ()) {
        copyItemOptions = { name: name };
    } else if (name is () || name == "") {
        copyItemOptions = { parentReference : check parentReference.cloneWithType(json) };
    } else {
        copyItemOptions = {
                            parentReference : check parentReference.cloneWithType(json),
                            name: name
                          };
    }      
    http:Response response = check httpClient->post(url, copyItemOptions);
    map<json>|string? handledResponse = check handleCopyItemResponse(response);
    if (handledResponse is string) {
        return handledResponse;
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function handleCopyItemResponse(http:Response httpResponse) returns @tainted string|Error? {
    if (httpResponse.statusCode == http:STATUS_ACCEPTED) {
        // long running JOB
        string locationHeader = check httpResponse.getHeader(http:LOCATION);
        AsyncJobStatus asyncStatus = check getasyncJobStatus(<@untainted>locationHeader); 
        return asyncStatus?.resourceId;
    }
    json errorPayload = check httpResponse.getJsonPayload();
    string message = errorPayload.toString(); 
    return error PayloadValidationError(message);
}
