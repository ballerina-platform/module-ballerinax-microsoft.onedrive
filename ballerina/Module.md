## Overview
Ballerina connector for Microsoft OneDrive connects to the OneDrive file storage API in Microsoft Graph v1.0 via the 
Ballerina language. The connector allows you to programmatically perform basic drive functionalities such as file 
upload, download. It also allows you to share files and folders stored on Microsoft OneDrive.

This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) `v1.0` and allows performing functions only on behalf of the currently signed-in user.
## Prerequisites
Before using this connector in your Ballerina application, complete the following:

* Create a [Microsoft 365 Personal account](https://www.office.com/)
* Create an [Azure account](https://azure.microsoft.com/en-us/) to register an application in the Azure portal
* Obtain tokens
    - Follow [Microsoft Documentation - Register an application with the Microsoft identity platform]](https://docs.microsoft.com/en-us/graph/auth-register-app-v2) to register an application with the Microsoft identity platform.

## Quickstart
To use the OneDrive connector in your Ballerina application, update the .bal file as follows:
### Step 1 - Import connector
Import the `ballerinax/microsoft.onedrive` module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2 - Create a new connector instance
To make the connection, use the OAuth2 refresh token grant configuration.
```ballerina
onedrive:ConnectionConfig configuration = {
    auth: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
    }
};
```
### Step 3 - Invoke connector operation

1. Create a folder <br/>
    To create a folder, use the following code block:

```ballerina
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
```

2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/examples)**
