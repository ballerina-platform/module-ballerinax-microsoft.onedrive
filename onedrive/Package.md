## Module Overview
Ballerina connector for Microsoft OneDrive is connecting to OneDrive file storage API in Microsoft Graph v1.0 via Ballerina 
language easily. It provides capability to perform basic drive functionalities including as Uploading, Downloading, 
Sharing files and folders which have been stored on Microsoft OneDrive programmatically. 

The connector is developed on top of Microsoft Graph is a REST web API that empowers you to access Microsoft Cloud 
service resources. This version of the connector only supports the access to the resources and information of a specific 
account (currently logged in user).

## Compatibility
Ballerina Language Version&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Swan Lake  Beta 3**<br/>
[Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) Version&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **v1.0**<br/>
Java Development Kit (JDK)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;11                    

## OneDrive Client
```ballerina
import ballerinax/microsoft.onedrive;

onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
    }
};

onedrive:Client driveClient = check new (config);
```
## Samples
### Create a folder in OneDrive
Create a new folder in a Drive with a specified parent item, referred with file system path (relative path).

```
import ballerina/http;
import ballerina/log;
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

    log:printInfo("Create a folder in a folder specified by ID");

    string parentID = "<PARENT_FOLDER_ID>";
    string newFolderName = "Samples_Test";
    onedrive:FolderMetadata item = {
        name: newFolderName,
        conflictResolutionBehaviour : "rename"
    };

    onedrive:DriveItemData|onedrive:Error driveItem = driveClient->createFolderById(parentID, item);

    if (driveItem is onedrive:DriveItemData) {
        log:printInfo("Folder Created " + driveItem.toString());
        log:printInfo("Success!");
    } else {
        log:printError(driveItem.message());
    }
}
```
### Upload a small file to OneDrive
Upload a new file to the Drive. This method only supports files up to 4MB in size.
```ballerina
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

    log:printInfo("Upload drive item to a folder with given item ID");

    byte[] byteArray = check io:fileReadBytes("<LOCAL_FILE_PATH>");
    string fileNameNewForNewUploadByPath = "<NEW_FILE_NAME>";
    string parentFolderPath = "<PARENT_FOLDER_PATH>";
    string mediaType = "image/png";

    onedrive:DriveItemData|onedrive:Error itemInfo = driveClient->uploadFileToFolderByPath(parentFolderPath, 
        fileNameNewForNewUploadByPath, byteArray, mediaType);
    if (itemInfo is onedrive:DriveItemData) {
        log:printInfo("Uploaded item " + itemInfo?.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(itemInfo.message());
    }
}
```
### Download a file from OneDrive
Download the contents of the primary stream (file) of a DriveItem using item ID.
```
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

    log:printInfo("Download drive item by path");

    string filePath = "<FILE_PATH>";
    
    onedrive:File|onedrive:Error itemResponse = driveClient->downloadFileByPath(filePath);
    if (itemResponse is onedrive:File) {
        byte[] content = let var item = itemResponse?.content in item is byte[] ? item : [];
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", content);
        log:printInfo("Success!");
    } else {
        log:printError(itemResponse.message());
    }
}
```
### Delete a drive item

```ballerina
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
    
    log:printInfo("Delete drive item by item ID");

    string itemId = "<TARGET_ITEM_ID>";

    onedrive:Error? deleteResponse = driveClient->deleteDriveItemById(itemId);
    if (deleteResponse is ()) {
        log:printInfo("Item deleted");
        log:printInfo("Success!");
    } else {
        log:printError(deleteResponse.message());
    }
}
```