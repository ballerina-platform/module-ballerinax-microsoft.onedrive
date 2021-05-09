## Module Overview
Ballerina connector for Microsoft OneDrive is connecting to OneDrive file storage API in Microsoft Graph v1.0 via Ballerina 
language easily. It provides capability to perform basic drive functionalities including as Uploading, Downloading, 
Sharing files and folders which have been stored on Microsoft OneDrive programmatically. 

The connector is developed on top of Microsoft Graph is a REST web API that empowers you to access Microsoft Cloud 
service resources. This version of the connector only supports the access to the resources and information of a specific 
account (currently logged in user).

## Compatibility
Ballerina Language Version&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Swan Lake Alpha 5**<br/>
Microsoft Graph API Version&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **v1.0**<br/>
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
Create a new folder in a Drive with a specified parent item, referred with file syatem path (relative path).

```
import ballerina/http;
import ballerina/log;
import ballerinax/microsoft.onedrive;

configurable http:OAuth2RefreshTokenGrantConfig & readonly driveOauthConfig = ?;

onedrive:Configuration config = {
    clientConfig : driveOauthConfig
};

onedrive:Client driveClient = check new (config);

public function main() {

    string parentsRelativepath = "/Sample_parent"; 
    string newFolderName = "Sample_Test";

    onedrive:FolderMetadata item = {
        name: newFolderName,
        folder: {},
        conflictResolutionBehaviour : "rename"
    };

    log:printInfo("Create a folder in a folder specified by path");
    onedrive:DriveItem|onedrive:Error driveItem = driveClient->createFolderByPath(parentRelativepath, item);

    if (driveItem is onedrive:DriveItem) {
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
import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerinax/microsoft.onedrive;

configurable http:OAuth2RefreshTokenGrantConfig & readonly driveOauthConfig = ?;

onedrive:Configuration config = {
    clientConfig : driveOauthConfig
};

onedrive:Client driveClient = check new (config);

public function main() {
    log:printInfo("Upload drive item to a folder with given item ID");

    stream<byte[],io:Error?> byteStream = checkpanic io:fileReadBlocksAsStream("files/logo.txt");
    string fileNameForNewUpload = "newUpload.txt";
    string parentFolderId = "<PARENT_FOLDER_ID>";

    onedrive:DriveItem|onedrive:Error itemInfo = driveClient->uploadDriveItemToFolderById(parentFolderId, 
        fileNameForNewUploadById, byteStream);
    if (itemInfo is onedrive:DriveItem) {
        log:printInfo("Uploaded item " + itemInfo?.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(itemInfo.message());
    }
}
```

### Download a file from OneDrive
Download the contents of the primary stream (file) of a DriveItem using item ID.



### Delete a drive item

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/microsoft.onedrive;

configurable http:OAuth2RefreshTokenGrantConfig & readonly driveOauthConfig = ?;

onedrive:Configuration config = {
    clientConfig : driveOauthConfig
};

onedrive:Client driveClient = check new (config);

public function main() {
    log:printInfo("Delete drive item by item ID");

    string itemId = "";

    onedrive:Error? deleteResponse = driveClient->deleteDriveItemById(itemId);
    if (deleteResponse is ()) {
        log:printInfo("Item deleted");
        log:printInfo("Success!");
    } else {
        log:printError(deleteResponse.message());
    }
}
```