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

import ballerina/file;
import ballerina/io;
import ballerina/log;
import ballerina/os;
import ballerinax/microsoft.onedrive;

configurable string & readonly refreshUrl = os:getEnv("REFRESH_URL");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

public function main() returns error? {
    onedrive:Configuration configuration = {
        clientConfig: {
            refreshUrl: refreshUrl,
            refreshToken : refreshToken,
            clientId : clientId,
            clientSecret : clientSecret,
            scopes: ["offline_access","https://graph.microsoft.com/Files.ReadWrite.All"]
        }
    };
    onedrive:Client driveClient = check new(configuration);

    log:printInfo("Upload large file to a folder with given path");

    string localFilePath = "<LOCAL_FILE_PATH>";

    stream<io:Block,io:Error?> fileStream = check io:fileReadBlocksAsStream(localFilePath, 
        onedrive:DEFAULT_FRAGMENT_SIZE*8);
    file:MetaData fileMetaData = check file:getMetaData(localFilePath);
    string uploadDestinationPath = "<UPLOAD_DETINATION_FILE_PATH_WITH_EXTENTION>";
    onedrive:UploadMetadata info = {
        fileSize : fileMetaData.size
    };

    onedrive:DriveItemData|onedrive:Error itemInfo = driveClient->resumableUploadDriveItem(uploadDestinationPath, info, 
        fileStream);
    if (itemInfo is onedrive:DriveItemData) {
        log:printInfo("Uploaded item " + itemInfo?.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(itemInfo.message());
    }
}
