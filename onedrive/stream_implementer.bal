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

class DriveItemStream {
    private DriveItem[] currentEntries = [];
    private string nextLink;
    int index = 0;
    private final http:Client httpClient;
    private final string path;

    isolated function init(http:Client httpClient, string path) returns @tainted Error? {
        self.httpClient = httpClient;
        self.path = path;
        self.nextLink = EMPTY_STRING;
        self.currentEntries = check self.fetchRecordsInitial();
    }

    public isolated function next() returns @tainted record {| DriveItem value; |}|Error? {
        if(self.index < self.currentEntries.length()) {
            record {| DriveItem value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        // This code block is for retrieving the next batch of records when the initial batch is finished.
        if (self.nextLink != EMPTY_STRING) {
            self.index = 0;
            self.currentEntries = check self.fetchRecordsNext();
            record {| DriveItem value; |} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
    }

    isolated function fetchRecordsInitial() returns @tainted DriveItem[]|Error {
        http:Response response = check self.httpClient->get(self.path);
        map<json>|string? handledResponse = check handleResponse(response);
        return check self.getAndConvertToDriveItemArray(response);
    }
    
    isolated function fetchRecordsNext() returns @tainted DriveItem[]|Error {
        http:Client nextPageClient = check new (self.nextLink);
        http:Response response = check nextPageClient->get(EMPTY_STRING);
        return check self.getAndConvertToDriveItemArray(response);
    }

    isolated function getAndConvertToDriveItemArray(http:Response response) returns @tainted DriveItem[]|error {
        DriveItem[] driveItems = [];
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            self.nextLink = let var link = handledResponse["@odata.nextLink"] in link is string ? link : EMPTY_STRING;
            json values = check handledResponse.value;
            if (values is json[]) {
                foreach json item in values {
                    DriveItem convertedItem = check convertToDriveItem(handledResponse);
                    driveItems.push(convertedItem);
                }
                return driveItems;
            } else {
                return error PayloadValidationError(INVALID_PAYLOAD);
            }
        } else {
            return error PayloadValidationError(INVALID_RESPONSE);
        }
    }
}
