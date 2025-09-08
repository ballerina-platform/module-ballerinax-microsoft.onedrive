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

import ballerina/io;
import ballerinax/microsoft.onedrive;

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

    onedrive:DriveCollectionResponse driveItems = check oneDrive->listDrive();
    onedrive:Drive[] items = driveItems.value ?: [];
    string driveId = from onedrive:Drive item in items
        where item["name"] == "OneDrive"
        limit 1
        select item.id ?: "";

    io:println("Creating Upload Folder");
    _ = check oneDrive->createChildrenInRoot(driveId,
        {
        name: "Upload",
        folder: {}
    });

    io:println("Uploading File");
    byte[] fileContent = checkpanic io:fileReadBytes("files/github.png");
    onedrive:DriveItem driveItem = check oneDrive->setChildrenContentByPath(
        driveId, "/Upload/github.png", fileContent);
    io:println(string `File Uploaded. File ID: ${driveItem.id ?: ""}`);

}
