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

import ballerina/io;
import ballerina/log;
import ballerinax/microsoft.onedrive;

configurable string & readonly refreshUrl = ?;
configurable string & readonly refreshToken = ?;
configurable string & readonly clientId = ?;
configurable string & readonly clientSecret = ?;

public function main() returns error? {
    onedrive:ConnectionConfig configuration = {
        auth: {
            refreshUrl: refreshUrl,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    };
    onedrive:Client driveClient = check new (configuration);

    log:printInfo("Replace file by referring item path");

    byte[] byteArray = check io:fileReadBytes("<LOCAL_FILE_PATH>");
    string filePath = "<FILE_PATH>";
    string mediType = "image/png";

    onedrive:DriveItemData|onedrive:Error itemInfo = driveClient->replaceFileUsingPath(filePath, byteArray, mediType);
    if (itemInfo is onedrive:DriveItemData) {
        log:printInfo("Replaced item " + itemInfo?.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(itemInfo.message());
    }
}
