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
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/test;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

Client oneDriveClient = check new Client(
    config = {
        auth: {
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: ["Files.Read", "Files.Read.All", "Files.ReadWrite", "Files.ReadWrite.All"]
        }
    }
);

string driveId = "";
string collectorFolderId = "";
string collectorFolderPath = "";
string newFolderId = "";
string newFolderPath = "";
string collectorCopyFolderPath = "";

string idOfFileInCollector = "";

@test:BeforeSuite
function testCreateFoldersAndFiles() returns error? {
    DriveCollectionResponse driveItems = check oneDriveClient->listDrive();
    Drive[] items = driveItems.value ?: [];

    driveId = from Drive item in items
        where item["name"] == "OneDrive"
        limit 1
        select item.id ?: "";

    test:assertNotEquals(driveId, "", msg = "Drive ID cannot be empty");

    runtime:sleep(2);
    log:printInfo("Creating Collector Folder");
    DriveItem collectorFolder = check oneDriveClient->createChildrenInRoot(driveId,
        {
        name: "Collector",
        folder: {}
    });
    log:printInfo("Collector Folder Created");
    collectorFolderId = collectorFolder.id ?: "";
    collectorFolderPath = "/Collector";
    test:assertNotEquals(collectorFolderId, "", msg = "Collector Folder ID cannot be empty");
}

@test:Config {
}
function testGetItemsSharedWithMe() returns error? {
    CollectionOfDriveItem driveItems = check oneDriveClient->sharedWithMe(driveId);
    DriveItem[] _ = driveItems.value ?: [];
}

@test:Config {
}
function testCreateFolder() returns error? {
    runtime:sleep(2);
    DriveItem newFolder = check oneDriveClient->createChildrenInRoot(driveId,
        {
        name: "Designs",
        folder: {
            childCount: 10,
            view: {
                sortBy: "name",
                sortOrder: "descending",
                viewType: "details"
            }
        }
    });
    newFolderId = newFolder.id ?: "";
    test:assertNotEquals(newFolderId, "", msg = "newFolderId cannot be empty");
}

@test:Config {
}
function testCreateFolderByPath() returns error? {
    runtime:sleep(2);

    runtime:sleep(2);
    DriveItem newFolder = check oneDriveClient->createItemByPath(driveId, "/Child_Designs",
        {
        name: "Child_Designs",
        folder: {
        }
    });
    test:assertNotEquals(newFolder.id ?: "", "", msg = "newFolderId cannot be empty");
    newFolderPath = "/Child_Designs";
}

@test:Config {
    dependsOn: [testCreateFolder]
}
function testGetItem() returns error? {
    runtime:sleep(2);

    DriveItem driveItem = check oneDriveClient->getItem(driveId, newFolderId);
    test:assertNotEquals(driveItem.id ?: "", "", msg = "driveItem id cannot be empty");
}

@test:Config {
    dependsOn: [testCreateFolderByPath]
}
function testGetItemByPath() returns error? {
    runtime:sleep(2);

    DriveItemCollectionResponse driveItemCollectionResponse =
        check oneDriveClient->listItemsByPath(driveId, "/Child_Designs");
    test:assertNotEquals(driveItemCollectionResponse.value, (), msg = "driveItemCollectionResponse cannot be empty");
}

@test:Config {
    dependsOn: [testGetItem]
}
function testUpdateDriveItem() returns error? {
    runtime:sleep(2);

    DriveItem driveItem = check oneDriveClient->updateItem(driveId, newFolderId,
    {
        name: "Canva_Folder",
        folder: {
            view: {
                sortBy: "type"
            },
            childCount: 9
        }
    });
    test:assertNotEquals(driveItem.id ?: "", "", msg = "driveItem id cannot be empty");
}

@test:Config {
    dependsOn: [testGetItemByPath]
}
function testUpdateDriveItemByPath() returns error? {
    runtime:sleep(2);

    DriveItem driveItem = check oneDriveClient->updateItemByPath(driveId, newFolderPath,
    {
        name: "Child_Canva",
        folder: {}
    });
    test:assertNotEquals(driveItem.id, (), msg = "driveItem id cannot be empty");
    newFolderPath = "/Child_Canva";
}

@test:Config {
    dependsOn: [testUpdateDriveItem, testUpdateDriveItemByPath]
}
function testMoveDriveItem() returns error? {
    runtime:sleep(2);
    DriveItem driveItem = check oneDriveClient->updateItem(driveId, newFolderId,
    {
        name: "Moved_to_Collector_Id",
        parentReference: {
            id: collectorFolderId //"root" cannot be used here as a value"
        }
    });
    test:assertNotEquals(driveItem.id, (), msg = "driveItem id cannot be empty");

    runtime:sleep(2);
    DriveItem driveItem2 = check oneDriveClient->updateItemByPath(driveId, newFolderPath,
    {
        name: "Moved_to_Collector_Path",
        parentReference: {
            id: collectorFolderId //"root" cannot be used here as a value"
        }
    });
    test:assertNotEquals(driveItem2.id, (), msg = "driveItem id cannot be empty");
    collectorCopyFolderPath = collectorFolderPath + "/Moved_to_Collector_Path";
}

@test:Config {
    dependsOn: [testMoveDriveItem]
}
function testCopyDriveItemInPath() returns error? {
    runtime:sleep(2);
    // Validate why no contemt is returned in this request
    DriveItem|error driveItem = oneDriveClient->copyByPath(driveId, collectorFolderPath, {
        name: "Collector_Copy_Path"
    });
    collectorCopyFolderPath = "/Collector_Copy_Path";
}

@test:Config {
    dependsOn: [testCopyDriveItemInPath]
}
function testDeleteDriveItemByPath() returns error? {
    runtime:sleep(2);
    check oneDriveClient->deleteItemByPath(driveId, collectorCopyFolderPath);
}

@test:Config {
}
function testUploadFileToFolder() returns error? {
    runtime:sleep(2);

    byte[] testFileContent = checkpanic io:fileReadBytes("tests/files/github.png");
    DriveItem driveItem = check oneDriveClient->setChildrenContent(driveId, collectorFolderId,
    "newUpload.png", testFileContent);
    test:assertNotEquals(driveItem.id, (), msg = "driveItem id cannot be empty");
    idOfFileInCollector = driveItem.id ?: "";
    io:println("File uploaded with ID: " + idOfFileInCollector);
}

@test:Config {
}
function testUploadFileToFolderByPath() returns error? {
    runtime:sleep(2);

    byte[] testFileContent = checkpanic io:fileReadBytes("tests/files/github.png");
    DriveItem driveItem = check oneDriveClient->setChildrenContentByPath(driveId,
    collectorFolderPath + "/newUploadByPath.png", testFileContent);
    test:assertNotEquals(driveItem.id, (), msg = "driveItem id cannot be empty");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadFileToFolder]
}
function testDownloadFileByPath() returns error? {
    runtime:sleep(5);

    byte[] content = check oneDriveClient->getChildrenContentByPath(driveId, collectorFolderPath + "/newUpload.png");
    io:Error? result = io:fileWriteBytes("tests/files/downloadedFile.png", content);
    if (result is io:Error) {
        log:printInfo(msg = result.message());
    }
}

@test:AfterSuite {}
function testDeleteFoldersAndFiles() returns error? {
    runtime:sleep(2);
    // Delete folders
    error? deleteResponse = oneDriveClient->deleteItem(driveId, collectorFolderId);

    if (deleteResponse is ()) {
        log:printInfo("Folders deleted");
        log:printInfo("Success!");
    } else {
        log:printError("Error in deleting resource.");
    }
}
