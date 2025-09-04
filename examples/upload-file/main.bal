// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerinax/microsoft.onedrive;
import ballerina/log;
import ballerina/io;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

public function main() returns error? {
    onedrive:Client oneDrive = check new (
        config = {
            auth: {
                refreshToken,
                clientId,
                clientSecret,
                scopes: ["Files.Read", "Files.Read.All", "Files.ReadWrite", "Files.ReadWrite.All"]
            }
        }
    );

    onedrive:microsoft\.graph\.driveCollectionResponse driveItems = check oneDrive->listDrive();
    onedrive:microsoft\.graph\.drive[] items = driveItems.value ?: [];
    string driveId = from onedrive:microsoft\.graph\.drive item in items
        where item["name"] == "OneDrive"
        limit 1
        select item.id ?: "";

    log:printInfo("Creating Upload Folder");
    _ = check oneDrive->createChildrenInRoot(driveId,
        {
        name: "Upload",
        folder: {}
    });

    log:printInfo("Upload File");
    byte[] fileContent = checkpanic io:fileReadBytes("files/github.png");
    onedrive:microsoft\.graph\.driveItem driveItem = check oneDrive->setChildrenContentByPath(
        driveId, "/Upload/github.png", fileContent);
    log:printInfo(string `File Uploaded. File ID: ${driveItem.id ?: ""}`);

}
