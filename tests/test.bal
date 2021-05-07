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
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/test;

configurable string & readonly refreshUrl = os:getEnv("TOKEN_ENDPOINT");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("APP_ID");
configurable string & readonly clientSecret = os:getEnv("APP_SECRET");

Configuration configuration = {
    clientConfig: {
        refreshUrl: refreshUrl,
        refreshToken : refreshToken,
        clientId : clientId,
        clientSecret : clientSecret,
        scopes: ["offline_access","https://graph.microsoft.com/Files.ReadWrite.All"]
    }
};

Client oneDriveClient = check new(configuration);

string sharedUrl = "";
string checkedInFile = "";
string followFile = "";
string previewFileLink = "";

string newFolderId = "";
string newFolderPath = "";
string collectorFolderId = "";
string collectorFolderPath = "";
string collectorCopyIdFolderId = "";
string collectorCopyPathFolderId = "";
string collectorCopyFolderPath = "";
string idOfFileInCollector = "";
string pathOfFileInCollector = "";

@test:BeforeSuite
function testCreateFoldersAndFiles() {
    runtime:sleep(2);
    log:printInfo("ACTION : CreateResources()");
    string parentID = "root";
    string newFolderName = "Collector";
    FolderMetadata item = {
        name: newFolderName,
        folder: { },
        conflictResolutionBehaviour : "rename"
    };

    DriveItem|Error driveItem = oneDriveClient->createFolderById(parentID, item);
    if (driveItem is DriveItem) {
        log:printInfo("Folder Created");
        collectorFolderId = <@untainted>driveItem?.id.toString();
        collectorFolderPath = "/Collector";
    } else {
        test:assertFail(msg = driveItem.message());
    }
}

@test:Config {
    enable: true
}
function testGetRecentItems() {
    log:printInfo("client->getRecentItems()");
    runtime:sleep(2);

    DriveItem[]|Error driveItems = oneDriveClient->getRecentItems();
    if (driveItems is DriveItem[]) {
        foreach var item in driveItems {
            log:printInfo("Item received " + item.toString());
        }
    } else {
        test:assertFail(msg = driveItems.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
}
function testGetItemsSharedWithMe() {
    log:printInfo("client->getItemsSharedWithMe()");
    runtime:sleep(2);

    DriveItem[]|Error driveItems = oneDriveClient->getItemsSharedWithMe();
    if (driveItems is DriveItem[]) {
        foreach var item in driveItems {
            log:printInfo("Item received " + item.toString());
        }
    } else {
        test:assertFail(msg = driveItems.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
}
function testCreateFolderById() {
    log:printInfo("client->CreateFolderById()");
    runtime:sleep(2);

    string parentID = "root";
    string newFolderName = "Designs";

    FolderMetadata item = {
        name: newFolderName,
        folder: { },
        conflictResolutionBehaviour : "rename"
    };
    DriveItem|Error driveItem = oneDriveClient->createFolderById(parentID, item);
    if (driveItem is DriveItem) {
        log:printInfo("Folder Created " + driveItem?.id.toString());
        newFolderId = <@untainted>driveItem?.id.toString();
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
}
function testCreateFolderByPath() {
    log:printInfo("client->CreateFolderByPath()");
    runtime:sleep(2);

    string parentRelativepath = ""; 
    string newFolderName = "Child_Designs";
    newFolderPath = parentRelativepath + FORWARD_SLASH + newFolderName;

    FolderMetadata item = {
        name: newFolderName,
        folder: { },
        conflictResolutionBehaviour : "rename"
    };
    DriveItem|Error driveItem = oneDriveClient->createFolderByPath(parentRelativepath, item);
    if (driveItem is DriveItem) {
        log:printInfo("Folder Created " + driveItem?.id.toString());
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateFolderById]
}
function testGetItemMetadataById() {
    log:printInfo("client->getItemMetadataById()");
    runtime:sleep(2);

    string itemId = newFolderId;
    
    DriveItem|Error driveItem = oneDriveClient->getItemMetadataById(itemId);
    if (driveItem is DriveItem) {
        log:printInfo("Item received " + driveItem.toString());
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateFolderByPath]
}
function testGetItemMetadataByPath() {
    log:printInfo("client->getItemMetadataByPath()");
    runtime:sleep(2);

    string itemPath = newFolderPath;
    DriveItem|Error driveItem = oneDriveClient->getItemMetadataByPath(itemPath);
    if (driveItem is DriveItem) {
        log:printInfo("Item received " + driveItem.toString());
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testMoveDriveItem]
}
function testGetItemMetadataByIdApplyQueryParams() {
    log:printInfo("client->getItemUsingQueryParams()");
    runtime:sleep(2);

    string itemId = collectorFolderId;
    string[] queryParams = ["$expand=children"];

    DriveItem|Error driveItem = oneDriveClient->getItemMetadataById(itemId, queryParams);
    if (driveItem is DriveItem) {
        log:printInfo("Item received " + driveItem.toString());
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testGetItemMetadataById]
}
function testUpdateDriveItemById() {
    log:printInfo("client->updateDriveItemById()");
    runtime:sleep(2);

    string itemId = newFolderId;
    DriveItem replacement = {
        name: "Canva",
        folder: {
            view: {
                sortBy: "type"
            },
            childCount: 9
        }
    };
    DriveItem|Error driveItem = oneDriveClient->updateDriveItemById(itemId, replacement);
    if (driveItem is DriveItem) {
        log:printInfo("Item updated " + driveItem.toString());
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testGetItemMetadataByPath]
}
function testUpdateDriveItemByPath() {
    log:printInfo("client->updateDriveItemByPath()");
    runtime:sleep(2);

    string itemPath = newFolderPath;
    DriveItem replacement = {
        name: "Child_Canva",
        folder : {}
    };
    DriveItem|Error driveItem = oneDriveClient->updateDriveItemByPath(itemPath, replacement);
    if (driveItem is DriveItem) {
        log:printInfo("Item updated " + driveItem.toString());
        newFolderPath = "/Child_Canva";
    } else {
        test:assertFail(msg = driveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUpdateDriveItemById, testUpdateDriveItemByPath]
}
function testMoveDriveItem() {
    log:printInfo("client->moveDriveItemById()");
    runtime:sleep(2);

    string itemIdtoMoveById = newFolderId;
    string parentFolderId = collectorFolderId;

    DriveItem replacement1 = {
        name: "Moved_to_Collector_Id",
        parentReference : {
            id: parentFolderId //"root" cannot be used here as a value"
        }
    };

    DriveItem|Error driveItemMovedById = oneDriveClient->updateDriveItemById(itemIdtoMoveById, replacement1);
    if (driveItemMovedById is DriveItem) {
        log:printInfo("Item moved " + driveItemMovedById.toString());
    } else {
        test:assertFail(msg = driveItemMovedById.message());
    }

    runtime:sleep(2);
    string itemPathtoMoveByPath = newFolderPath;
    parentFolderId = collectorFolderId;

    DriveItem replacement2 = {
        name: "Moved_to_Collector_Path",
        parentReference : {
            id: parentFolderId //"root" cannot be used here as a value"
        }
    };

    DriveItem|Error driveItemMovedByPath = oneDriveClient->updateDriveItemByPath(itemPathtoMoveByPath, replacement2);
    if (driveItemMovedByPath is DriveItem) {
        log:printInfo("Item moved " + driveItemMovedByPath.toString());
        collectorCopyFolderPath = collectorFolderPath + "/Moved_to_Collector_Path";
    } else {
        test:assertFail(msg = driveItemMovedByPath.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testMoveDriveItem]
}
function testDeleteDriveItemById() {
    log:printInfo("client->deleteDriveItemById()");
    runtime:sleep(2);

    string itemId = collectorCopyIdFolderId;

    Error? deleteResponse = oneDriveClient->deleteDriveItemById(itemId);
    if (deleteResponse is ()) {
        log:printInfo("Item deleted");
    } else {
        test:assertFail(msg = deleteResponse.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testMoveDriveItem]
}
function testDeleteDriveItemByPath() {
    log:printInfo("client->deleteDriveItemByPath()");
    runtime:sleep(2);

    string itemPath = collectorCopyFolderPath;
    Error? deleteResponse = oneDriveClient->deleteDriveItemByPath(itemPath);
    if (deleteResponse is ()) {
        log:printInfo("Item deleted");
    } else {
        test:assertFail(msg = deleteResponse.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testDeleteDriveItemById]
}
function testRestoreDriveItem() {
    log:printInfo("client->restoreDriveItem()");
    runtime:sleep(2);

    string itemId = collectorCopyIdFolderId;

    DriveItem|Error restoredDriveItem = oneDriveClient->restoreDriveItem(itemId);
    if (restoredDriveItem is DriveItem) {
        log:printInfo("Item restored "+ restoredDriveItem?.id.toString());
    } else {
        test:assertFail(msg = restoredDriveItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testMoveDriveItem]
}
function testCopyDriveItemById() {
    log:printInfo("client->copyDriveItemById()");
    runtime:sleep(2);
    // if there is a copy of same file already exists in the destination folder this operation will fail

    // string driveId = "f8c35d256a873b4b";
    // string destinationFolderId = "F8C35D256A873B4B!134";
    string itemId = collectorFolderId;
    string itemCopyName = "Collector_Copy_Id";

    string|Error resourceId = oneDriveClient->copyDriveItemWithId(itemId, itemCopyName); 
    if (resourceId is string) {
        log:printInfo("Created a copy in with id " + resourceId);
        collectorCopyIdFolderId = <@untainted>resourceId;
    } else {
        test:assertFail(msg = resourceId.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testMoveDriveItem]
}
function testCopyDriveItemInPath() {
    log:printInfo("client->copyDriveItemInPath()");
    runtime:sleep(2);
    // if there is a copy of same file already exists in the destination folder this operation will fail

    // string driveId = "f8c35d256a873b4b";
    // string destinationFolderId = "F8C35D256A873B4B!134";
    string itemPath = collectorFolderPath;
    string itemCopyName = "Collector_Copy_Path";

    string|Error resourceId = oneDriveClient->copyDriveItemInPath(itemPath, itemCopyName); 
    if (resourceId is string) {
        log:printInfo("Created a copy in with id " + resourceId);
        collectorCopyPathFolderId = <@untainted>resourceId;
    } else {
        test:assertFail(msg = resourceId.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
}
function testUploadDriveItemToFolderById() {
    log:printInfo("client->uploadDriveItemToFolderById()");
    runtime:sleep(2);

    stream<byte[],io:Error?> byteArray = checkpanic io:fileReadBlocksAsStream("files/logo.txt");
    string fileNameForNewUploadById = "newUpload.txt";
    string parentFolderId = collectorFolderId;

    DriveItem|Error itemInfo = oneDriveClient->uploadDriveItemToFolderById(parentFolderId, fileNameForNewUploadById, 
        byteArray);
    if (itemInfo is DriveItem) {
        log:printInfo("Uploaded item " + itemInfo?.id.toString());
        idOfFileInCollector = <@untainted>itemInfo?.id.toString();
    } else {
        test:assertFail(msg = itemInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true
}
function testUploadDriveItemToFolderByPath() {
    log:printInfo("client->uploadDriveItemToFolderByPath()");
    runtime:sleep(2);

    stream<byte[],io:Error?> byteArray = checkpanic io:fileReadBlocksAsStream("files/logo.txt");
    string fileNameNewForNewUploadByPath = "newUploadByPath.txt";
    string parentFolderPath = collectorFolderPath;

    DriveItem|Error itemInfo = oneDriveClient->uploadDriveItemToFolderByPath(parentFolderPath, 
        fileNameNewForNewUploadByPath, byteArray);
    if (itemInfo is DriveItem) {
        log:printInfo("Uploaded item " + itemInfo?.id.toString());
        pathOfFileInCollector = collectorFolderPath + FORWARD_SLASH + fileNameNewForNewUploadByPath;
    } else {
        test:assertFail(msg = itemInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderById]
}
function testDownloadFileById() {
    log:printInfo("client->downloadFileById()");
    runtime:sleep(2);

    string fileId = idOfFileInCollector;
    //string fileId = "F8C35D256A873B4B!102";

    File|Error itemResponse = oneDriveClient->downloadFileById(fileId);
    if (itemResponse is File) {
        byte[] content = let var item = itemResponse?.content in item is byte[] ? item : [];
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", content);    
    } else {
        test:assertFail(msg = itemResponse.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderByPath]
}
function testDownloadFileByPath() {
    log:printInfo("client->downloadFileByPath()");
    runtime:sleep(2);

    string filePath = pathOfFileInCollector;
    
    File|Error itemResponse = oneDriveClient->downloadFileByPath(filePath);
    if (itemResponse is File) {
        byte[] content = let var item = itemResponse?.content in item is byte[] ? item : [];
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", content);    
    } else {
        test:assertFail(msg = itemResponse.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderById]
}
function testDownloadConvertedFileContentById() {
    log:printInfo("client->downloadConvertedFileContentById()");
    runtime:sleep(2);

    string fileId = idOfFileInCollector;
    FileFormat expectedFormat = MIMETYPE_DOCX; /////////

    File|Error itemResponse = oneDriveClient->downloadFileById(fileId, expectedFormat);
    if (itemResponse is File) {
        byte[] content = let var item = itemResponse?.content in item is byte[] ? item : [];
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", content);    
    } else {
        test:assertFail(msg = itemResponse.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderByPath]
}
function testDownloadConvertedFileContentByPath() {
    log:printInfo("client->downloadConvertedFileContentByPath()");
    runtime:sleep(2);

    string filePath = pathOfFileInCollector;
    FileFormat expectedFormat = MIMETYPE_DOCX;
    File|Error itemResponse = oneDriveClient->downloadFileByPath(filePath, expectedFormat);
    if (itemResponse is File) {
        byte[] content = let var item = itemResponse?.content in item is byte[] ? item : [];
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", content);
    } else {
        test:assertFail(msg = itemResponse.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testDownloadConvertedFileContentById]
}
function testReplaceFileUsingId() {
    log:printInfo("client->replaceFileUsingId()");
    runtime:sleep(2);

    byte[] byteArray = checkpanic io:fileReadBytes("files/github.png");
    string fileId = idOfFileInCollector;

    DriveItem|Error itemInfo = oneDriveClient->replaceFileUsingId(fileId, byteArray);
    if (itemInfo is DriveItem) {
        log:printInfo("Replaced item " + itemInfo?.id.toString());
    } else {
        test:assertFail(msg = itemInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testDownloadConvertedFileContentByPath]
}
function testReplaceFileUsingPath() {
    log:printInfo("client->replaceFileUsingPath()");
    runtime:sleep(2);

    byte[] byteArray = checkpanic io:fileReadBytes("files/github.png");
    string filePath = pathOfFileInCollector;

    DriveItem|Error itemInfo = oneDriveClient->replaceFileUsingPath(filePath, byteArray);
    if (itemInfo is DriveItem) {
        log:printInfo("Replaced item " + itemInfo?.id.toString());
    } else {
        test:assertFail(msg = itemInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderByPath]
}
function testResumableUploadDriveItem() {
    log:printInfo("client->resumableUploadDriveItem()");
    runtime:sleep(2);

    string fileName = "logo.txt";
    //string fileName = "ServiceNow_IntegrationSOAP.mp4";
    string localFilePath = "files" + FORWARD_SLASH + fileName;
    //string filePath = "files/ServiceNow_IntegrationREST.mp4";
    //string fileName = "training.txt";
    stream<io:Block,io:Error?> fileStream = checkpanic io:fileReadBlocksAsStream(localFilePath, DEFAULT_FRAGMENT_SIZE*6);

    byte[]  bytes = checkpanic io:fileReadBytes(localFilePath);
    file:MetaData fileMetaData = checkpanic file:getMetaData(localFilePath);
    string uploadDestination = collectorFolderPath + FORWARD_SLASH + fileName;
    ItemInfo info = {
        fileSize : fileMetaData.size
    };

    DriveItem|Error itemInfo = oneDriveClient->resumableUploadDriveItem(uploadDestination, info, fileStream);
    if (itemInfo is DriveItem) {
        log:printInfo("Uploaded item " + itemInfo?.id.toString());
    } else {
        test:assertFail(msg = itemInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testReplaceFileUsingPath]
}
function testSearchDriveItems() {
    log:printInfo("client->searchDriveItems()");
    runtime:sleep(2);

    string searchText = "newUploadByPath";
    stream<DriveItem, Error>|Error itemStream = oneDriveClient->searchDriveItems(searchText);
    if (itemStream is stream<DriveItem, Error>) {
        Error? e = itemStream.forEach(isolated function (DriveItem queryResult) {
            log:printInfo(queryResult.toString());
        });
    } else {
        test:assertFail(msg = itemStream.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderById]
}
function testGetSharableLinkFromId() {
    log:printInfo("client->getSharableLinkFromId()");
    runtime:sleep(2);

    PermissionOptions options = {
        'type: "view",
        scope: "anonymous"
    };
    string itemId = idOfFileInCollector;

    Permission|Error permission = oneDriveClient->getSharableLinkFromId(itemId, options);
    if (permission is Permission) {
        log:printInfo("Download shared file from " + permission?.link?.webUrl.toString());
        sharedUrl = permission?.link?.webUrl.toString();
    } else {
        test:assertFail(msg = permission.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderByPath]
}
function testGetSharableLinkFromPath() {
    log:printInfo("client->getSharableLinkFromPath()");
    runtime:sleep(2);

    PermissionOptions options = {
        'type: "view",
        scope: "anonymous"
    };

    string itemPath = pathOfFileInCollector;
    Permission|Error permission = oneDriveClient->getSharableLinkFromPath(itemPath, options);
    if (permission is Permission) {
        log:printInfo("Download shared file from " + permission?.link?.webUrl.toString());
        sharedUrl = permission?.link?.webUrl.toString();
    } else {
        test:assertFail(msg = permission.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testGetSharableLinkFromId]
}
function testGetSharedDriveItem() {
    log:printInfo("client->getSharedDriveItem()");
    runtime:sleep(2);

    DriveItem|Error sharedItem = oneDriveClient->getSharedDriveItem(sharedUrl);
    if (sharedItem is DriveItem) {
        log:printInfo("Shared item info " + sharedItem.toString());
    } else {
        test:assertFail(msg = sharedItem.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderById]
}
function testSendSharingInvitationById() {
    log:printInfo("client->sendSharingInvitationById()");
    runtime:sleep(2);

    string fileToShareWithInvitation = idOfFileInCollector;
    ItemShareInvitation invitation = {
        roles: ["write"],
        recipients: [
            {
                email: "tishchethya@gmail.com"
            }
        ]
    };

    Permission|Error sharedPermisson = oneDriveClient->sendSharingInvitationById(fileToShareWithInvitation, invitation);
    if (sharedPermisson is Permission) {
        log:printInfo("Shared permission info" + sharedPermisson.toString());
    } else {
        test:assertFail(msg = sharedPermisson.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUploadDriveItemToFolderByPath]
}
function testSendSharingInvitationByPath() {
    log:printInfo("client->sendSharingInvitationByPath()");
    runtime:sleep(2);

    string fileLocationToShare = pathOfFileInCollector;
    ItemShareInvitation invitation = {
        roles: ["write"],
        recipients: [
            {
                email: "tishchethya@gmail.com"
            }
        ]
    };
    Permission|Error sharedPermisson = oneDriveClient->sendSharingInvitationByPath(fileLocationToShare, invitation);
    if (sharedPermisson is Permission) {
        log:printInfo("Shared permission info" + sharedPermisson.toString());
    } else {
        test:assertFail(msg = sharedPermisson.message());
    }
    io:println("\n\n");
}

// *************************Supported only in Azure work and School accounts (NOT TESTED) **************************
// @test:Config {
//     enable: true
// }
// function testCheckInDriveItem() {
//     log:printInfo("client->checkInDriveItem()");
//     runtime:sleep(2);

//     CheckInOptions options = {
//         comment: "Check In"
//     };
//     error? result = oneDriveClient->checkInDriveItem(checkedInFile, options);
//     if (result is ()) {
//         log:printInfo("CheckIn success");
//     } else {
//         test:assertFail(msg = result.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     dependsOn: [testCheckInDriveItem],
//     enable: true
// }
// function testCheckOutDriveItem() {
//     log:printInfo("client->checkOutDriveItem()");
//     runtime:sleep(2);

//     error? result = oneDriveClient->checkOutDriveItem(checkedInFile);
//     if (result is ()) {
//         log:printInfo("CheckIn success");
//     } else {
//         test:assertFail(msg = result.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     enable: true
// }
// function testFollowDriveItem() {
//     log:printInfo("client->followDriveItem()");
//     runtime:sleep(2);

//     DriveItem|Error followedDeiveItem = oneDriveClient->followDriveItem(followFile);
//     if (followedDeiveItem is DriveItem) {
//         log:printInfo("Item followed "+ followedDeiveItem?.id.toString());
//     } else {
//         test:assertFail(msg = followedDeiveItem.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     dependsOn: [testFollowDriveItem],
//     enable: true
// }
// function testUnfollowDriveItem() {
//     log:printInfo("client->unfollowDriveItem()");
//     runtime:sleep(2);

//     error? unfollowResponse = oneDriveClient->unfollowDriveItem(followFile);
//     if (unfollowResponse is error) {
//         test:assertFail(msg = unfollowResponse.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     enable: true
// }
// function testGetItemsFollowed() {
//     log:printInfo("client->getItemsFollowed()");
//     runtime:sleep(2);

//     DriveItem[]|Error driveItems = oneDriveClient->getItemsFollowed();
//     if (driveItems is DriveItem[]) {
//         foreach var item in driveItems {
//             log:printInfo("Item received " + item.toString());
//         }
//     } else {
//         test:assertFail(msg = driveItems.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     enable: true
// }
// function testGetDriveItemPreview() {
//     log:printInfo("client->getDriveItemPreview()");
//     runtime:sleep(2);

//     PreviewOptions options = {
//         zoom: 10
//     };

//     EmbeddableData|Error emeddableData = oneDriveClient->getDriveItemPreview(previewFileLink, options);
//     if (emeddableData is EmbeddableData) {
//         log:printInfo("Download shared file from " + emeddableData.toString());
//     } else {
//         test:assertFail(msg = emeddableData.message());
//     }
//     io:println("\n\n");
// }

// @test:Config {
//     enable: true
// }
// function testGetItemStatistics() {
//     log:printInfo("client->getItemStatistics()");
//     runtime:sleep(2);

//     string driveId = "root";
//     string itemId = "F8C35D256A873B4B!132"; //GIT to sheet img;

//     ItemAnalytics|Error analytics = oneDriveClient->getItemStatistics(driveId, itemId);
//     if (analytics is ItemAnalytics) {
//         log:printInfo("Item received " + analytics.toString());
//     } else {
//         test:assertFail(msg = analytics.message());
//     }
//     io:println("\n\n");
// }

@test:AfterSuite {}
function testDeleteFoldersAndFiles() {
    runtime:sleep(2);
    // Delete folders
    string itemPath = collectorFolderPath;
    error? deleteResponse1 = oneDriveClient->deleteDriveItemByPath(itemPath);
    error? deleteResponse2 = oneDriveClient->deleteDriveItemById(collectorCopyPathFolderId);
    error? deleteResponse3 = oneDriveClient->deleteDriveItemById(collectorCopyIdFolderId);

    if (deleteResponse1 is () && deleteResponse2 is () && deleteResponse3 is ()) {
        log:printInfo("Folders deleted");
        log:printInfo("Success!");
    } else {
        log:printError("One of the resources is not deleted.");
    }
}
