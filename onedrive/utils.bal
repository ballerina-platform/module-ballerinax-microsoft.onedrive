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
import ballerina/regex;

isolated function handleResponse(http:Response httpResponse) returns @tainted map<json>|Error? {
    if (httpResponse.statusCode is http:STATUS_OK|http:STATUS_CREATED|http:STATUS_ACCEPTED) {
        json jsonResponse = check httpResponse.getJsonPayload();
        return <map<json>>jsonResponse;
    } else if (httpResponse.statusCode is http:STATUS_NO_CONTENT) {
        return;
    }
    json errorPayload = check httpResponse.getJsonPayload();
    string message = errorPayload.toString(); // Error should be defined as a user defined object
    return error PayloadValidationError(message);
}

isolated function encodeSharingUrl(string sharingUrl) returns string {
    string sharingUrlBase64 = sharingUrl.toBytes().toBase64();
    int? lastIndex = sharingUrlBase64.lastIndexOf(EQUAL_SIGN);
    if (lastIndex is int) {
        sharingUrlBase64 = sharingUrlBase64.substring(ZERO, lastIndex);
    }
    string replacedString1 = regex:replaceAll(sharingUrlBase64, FORWARD_SLASH, UNDERSCORE);
    string replacedString2 = regex:replaceAll(replacedString1, PLUS_REGEX, MINUS_SIGN);
    return URL_PREFIX.concat(replacedString1);
}

isolated function createUrl(string[] pathParameters, string[] queryParameters = []) returns string|error {
    string url = EMPTY_STRING;
    if (pathParameters.length() > ZERO) {
        foreach string element in pathParameters {
            if (!element.startsWith(FORWARD_SLASH)) {
                url = url + FORWARD_SLASH;
            }
            url += element;
        }
    }
    if (queryParameters.length() > ZERO) {
        url = url + check appendQueryOption(queryParameters[ZERO], QUESTION_MARK);
        foreach string element in queryParameters.slice(1, queryParameters.length()) {
            url += check appendQueryOption(element, AMPERSAND);
        }
    }
    return url;
}

isolated function createPathBasedUrl(string[] pathParametersBefore, string relativePathParameters,
                                     string[] pathParametersAfter = [], string[] queryParameters = [])
                                     returns string|error {
    string url = EMPTY_STRING;
    string beforeParameters = check createUrl(pathParametersBefore);
    string afterParameters = check createUrl(pathParametersAfter);
    url = beforeParameters + ":" + relativePathParameters + ":" + afterParameters;
    return url;
}

isolated function appendQueryOption(string queryParameter, string connectingString) returns string|Error {
    string url = EMPTY_STRING;
    int? indexOfEqual = queryParameter.indexOf(EQUAL_SIGN);
    if (indexOfEqual is int) {
        string queryOptionName = queryParameter.substring(ZERO, indexOfEqual);
        string queryOptionValue = queryParameter.substring(indexOfEqual);
        if (queryOptionName.startsWith(DOLLAR_SIGN)) {
            if (validateOdataSystemQueryOption(queryOptionName.substring(1), queryOptionValue)) {
                url += connectingString + queryParameter;
            } else {
                return error QueryParameterValidationError(INVALID_QUERY_PARAMETER);
            }
        } else {
            // non odata query parameters
            url += connectingString + queryParameter;
        }
    } else {
        return error QueryParameterValidationError(INVALID_QUERY_PARAMETER);
    }
    return url;
}

isolated function validateOdataSystemQueryOption(string queryOptionName, string queryOptionValue) returns boolean {
    boolean isValid = false;
    string[] characterArray = [];
    if (queryOptionName is SystemQueryOption) {
        isValid = true;
    } else {
        return false;
    }
    foreach string character in queryOptionValue {
        if (character is OpeningCharacters) {
            characterArray.push(character);
        } else if (character is ClosingCharacters) {
            _ = characterArray.pop();
        }
    }
    if (characterArray.length() == ZERO){
        isValid = true;
    }
    return isValid;
}

isolated function getDriveItemArray(http:Client httpClient, string url) returns @tainted DriveItem[]|Error {
    http:Response response = check httpClient->get(url);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        json responseArray = check handledResponse.value;
        return check convertToDriveItemArray(<json[]>responseArray);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function getDriveItem(http:Client httpClient, string url) returns @tainted DriveItem|Error {
    http:Response response = check httpClient->get(url);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function createFolder(http:Client httpClient, string url, FolderMetadata itemMetadata) returns 
                               @tainted DriveItem|Error {
    json payload = check itemMetadata.cloneWithType(json);
    _ = check payload.mergeJson({"@microsoft.graph.conflictBehavior": itemMetadata?.conflictResolutionBehaviour});
    http:Response response = check httpClient->post(url, payload);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check convertToDriveItem(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }   
}

isolated function updateDriveItem(http:Client httpClient, string url, DriveItem replacementData) returns 
                                  @tainted DriveItem|Error {
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
    if (response.statusCode is http:STATUS_OK) {
        byte[] content = check response.getBinaryPayload();
        return {
            content: content,
            mediaType: response.getContentType()
        };  
    } else {
        json errorPayload = check response.getJsonPayload();
        string message = errorPayload.toString(); // Error should be defined as a user defined object
        return error PayloadValidationError(message);
    }
}

isolated function handleDownloadPrtialItem(string webUrl, map<string> headerMap) returns @tainted File|Error {
    http:Client downloadClient = check new(webUrl);
    http:Response response = check downloadClient->get(EMPTY_STRING, headerMap);
    if (response.statusCode is http:STATUS_OK|http:STATUS_PARTIAL_CONTENT) {
        byte[] content = check response.getBinaryPayload();
        return {
            content: content,
            mediaType: response.getContentType()
        }; 
    } else {
        json errorPayload = check response.getJsonPayload();
        string message = errorPayload.toString(); // Error should be defined as a user defined object
        return error PayloadValidationError(message);
    }
}

isolated function uploadDriveItem(http:Client httpClient, string url, stream<byte[],io:Error?> binaryStream, 
                                  string mediaType) returns @tainted DriveItem|Error {
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
                                           returns @tainted DriveItem|Error {
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
    string message = errorPayload.toString(); // Error should be defined as a user defined object
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
    http:Response response = check httpClient->post(url, permissionOptions);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(Permission);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function sendSharableLink(http:Client httpClient, string url, ItemShareInvitation invitation) returns 
                                   @tainted Permission|Error {
    boolean isValid = let var message = invitation?.message in message is string ? message.length() >= MAX_CHAR_COUNT ? 
        false : true : true; 
    if (!isValid) {
        return error PayloadValidationError(INVALID_MESSAGE);
    }              
    json shareInvitation = check invitation.cloneWithType(json);
    http:Response response = check httpClient->post(url, shareInvitation);
    map<json>|string? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(Permission);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function copyDriveItem(http:Client httpClient, string url, ItemReference? parentReference, string? name) 
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
    string message = errorPayload.toString(); // Error should be defined as a user defined object
    return error PayloadValidationError(message);
}

isolated function getasyncJobStatus(string monitorUrl) returns @tainted AsyncJobStatus|error {
    http:Client httpClient = check new(monitorUrl);
    http:Response response = check httpClient->get(EMPTY_STRING);
    if (response.statusCode is http:STATUS_OK|http:STATUS_ACCEPTED|http:REDIRECT_SEE_OTHER_303) {
        json jsonResponse = check response.getJsonPayload();
        AsyncJobStatus asyncStatus = check jsonResponse.cloneWithType(AsyncJobStatus);
        if (asyncStatus?.percentageComplete == HUNDRED && asyncStatus?.status == COMPLETED) {
            return asyncStatus;
        } else if (asyncStatus?.status == FAILED || asyncStatus?.status == DELETE_FAILED) {
            return error RequestFailedError(ASYNC_REQUEST_FAILED);
        } else {
            return check getasyncJobStatus(monitorUrl);
        }
    }
    json errorPayload = check response.getJsonPayload();
    string message = errorPayload.toString(); // Error should be defined as a user defined object
    return error PayloadValidationError(message);
}
