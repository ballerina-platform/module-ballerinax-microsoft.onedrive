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
import ballerina/regex;

isolated function handleResponse(http:Response httpResponse) returns map<json>|Error? {
    if (httpResponse.statusCode is http:STATUS_OK|http:STATUS_CREATED|http:STATUS_ACCEPTED) {
        json jsonResponse = check httpResponse.getJsonPayload();
        return <map<json>>jsonResponse;
    } else if (httpResponse.statusCode is http:STATUS_NO_CONTENT) {
        return;
    }
    json errorPayload = check httpResponse.getJsonPayload();
    string message = errorPayload.toString(); 
    return error PayloadValidationError(message);
}

isolated function encodeSharingUrl(string sharingUrl) returns string {
    string sharingUrlBase64 = sharingUrl.toBytes().toBase64();
    int? lastIndex = sharingUrlBase64.lastIndexOf(EQUAL_SIGN);
    if (lastIndex is int) {
        sharingUrlBase64 = sharingUrlBase64.substring(ZERO, lastIndex);
    }
    string replacedString1 = regex:replaceAll(sharingUrlBase64, FORWARD_SLASH, UNDERSCORE);
    _ = regex:replaceAll(replacedString1, PLUS_REGEX, MINUS_SIGN);
    return URL_PREFIX.concat(replacedString1);
}

isolated function createUrl(string[] pathParameters, string? queryParameters = ()) returns string|error {
    string url = EMPTY_STRING;
    if (pathParameters.length() > ZERO) {
        foreach string element in pathParameters {
            if (!element.startsWith(FORWARD_SLASH)) {
                url = url + FORWARD_SLASH;
            }
            url += element;
        }
    }
    if (queryParameters is string) {
        url = url + QUESTION_MARK + queryParameters;
    }
    return url;
}

isolated function createPathBasedUrl(string[] pathParametersBefore, string relativePathParameters,
                                     string[] pathParametersAfter = [], string? queryParameters = ())
                                     returns string|error {
    string url = EMPTY_STRING;
    string beforeParameters = check createUrl(pathParametersBefore);
    string afterParameters = check createUrl(pathParametersAfter);
    url = beforeParameters + ":" + relativePathParameters + ":" + afterParameters;
    if (queryParameters is string) {
        url = url + QUESTION_MARK + queryParameters;
    }
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
        if (matchOpening(character)) {
            characterArray.push(character);
        } else if (matchClosing(character)) {
            _ = characterArray.pop();
        }
    }
    if (characterArray.length() == ZERO){
        isValid = true;
    }
    return isValid;
}

isolated function getasyncJobStatus(string monitorUrl) returns AsyncJobStatus|error {
    http:Client httpClient = check new (monitorUrl, {
        httpVersion: http:HTTP_1_1,
        http1Settings: {
            chunking: http:CHUNKING_NEVER
        }
    });
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
    string message = errorPayload.toString(); 
    return error PayloadValidationError(message);
}

isolated function matchOpening(string value) returns boolean {
    match value {
        OPEN_BRACKET|OPEN_SQURAE_BRACKET|OPEN_CURLY_BRACKET|SINGLE_QUOTE_O|DOUBLE_QUOTE_O => {
            return true;
        }
    }
    return false;
}

isolated function matchClosing(string value) returns boolean {
    match value {
        CLOSE_BRACKET|CLOSE_SQURAE_BRACKET|CLOSE_CURLY_BRACKET|SINGLE_QUOTE_C|DOUBLE_QUOTE_C => {
            return true;
        }
    }
    return false;
}

# Resource that provide the progress of the long running action.
#
# + operation - The type of long running operation
# + percentageComplete - A value between 0 and 100 that indicates the percentage complete 
# + resourceId - ID of the relevent DriveItem 
# + status - String value that maps to an enumeration of possible values about the status of the job
type AsyncJobStatus record {
    string operation?;
    float percentageComplete?;
    string resourceId?;
    AsyncJobStatusString status?;
};
