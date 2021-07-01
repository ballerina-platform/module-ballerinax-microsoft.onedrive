## Overview
Ballerina connector for Microsoft OneDrive is connecting to OneDrive file storage API in Microsoft Graph v1.0 via Ballerina 
language easily. It provides capability to perform basic drive functionalities including as Uploading, Downloading, 
Sharing files and folders which have been stored on Microsoft OneDrive programmatically. 

This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) v1.0 version and only allows to perform functions behalf of the currently logged in user.
 
## Configuring connector
### Prerequisites
- Microsoft Office365 Personal account
- Access to register an application in Azure portal

### Obtaining tokens
Follow the following steps below to obtain the configurations.

1. Before you run the following steps, create an account in [OneDrive](https://onedrive.live.com). Next, sign into [Azure Portal - App Registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade). You can use your personal or work or school account to register.

2. In the App registrations page, click **New registration** and enter a meaningful name in the name field.

3. In the **Supported account types** section, select **Accounts in any organizational directory (Any Azure AD directory - Multi-tenant) and personal Microsoft accounts (e.g., Skype, Xbox, Outlook.com)** or **Personal Microsoft accounts only**. Click **Register** to create the application.
    
4. Copy the Application (client) ID (`<CLIENT_ID>`). This is the unique identifier for your app.
    
5. In the application's list of pages (under the **Manage** tab in left hand side menu), select **Authentication**.
    Under **Platform configurations**, click **Add a platform**.

6. Under **Configure platforms**, click **Web** located under **Web applications**.

7. Under the **Redirect URIs text box**, register the https://login.microsoftonline.com/common/oauth2/nativeclient url.
   Under **Implicit grant**, select **Access tokens**. Click **Configure**.

8. Under **Certificates & Secrets**, create a new client secret (`<CLIENT_SECRET>`). This requires providing a description and a period of expiry. Next, click **Add**.

9. Next, you need to obtain an access token and a refresh token to invoke the Microsoft Graph API.
First, in a new browser, enter the below URL by replacing the `<CLIENT_ID>` with the application ID.

    ```
    https://login.microsoftonline.com/common/oauth2/v2.0/authorize?response_type=code&client_id=<CLIENT_ID>&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&scope=Files.ReadWrite.All offline_access
    ```

10. This will prompt you to enter the username and password for signing into the Azure Portal App.

11. Once the username and password pair is successfully entered, this will give a URL as follows on the browser address bar.

    ```
    https://login.microsoftonline.com/common/oauth2/nativeclient?code=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```

12. Copy the code parameter (`xxxxxxxxxxxxxxxxxxxxxxxxxxx` in the above example) and in a new terminal, enter the following cURL command by replacing the `<CODE>` with the code received from the above step. The `<CLIENT_ID>` and `<CLIENT_SECRET>` parameters are the same as above.

    ```
    curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<CLIENT_ID>&client_secret=<CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&code=<CODE>&scope=Files.ReadWrite.All offline_access" https://login.microsoftonline.com/common/oauth2/v2.0/token
    ```

    The above cURL command should result in a response as follows.
    ```
    {
      "token_type": "Bearer",
      "scope": "openid Files.ReadWrite.All",
      "expires_in": 3600,
      "ext_expires_in": 3600,
      "access_token": "<ACCESS_TOKEN>",
      "refresh_token": "<REFRESH_TOKEN>"
    }
    ```

13. Provide the following configuration information in the `Config.toml` file to use the Microsoft OneDrive connector.

    ```ballerina
    clientId = <CLIENT_ID>
    clientSecret = <CLIENT_SECRET>
    refreshUrl = <REFRESH_URL>
    refreshToken = <REFRESH_TOKEN>
    ```

## Quickstart
## Create a folder in OneDrive
### Step 1: Import OneDrive Package
First, import the ballerinax/microsoft.onedrive module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};
```
### Step 3: Create a folder
```string parentID = "<PARENT_FOLDER_ID>";
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
## Upload a file to OneDrive
### Step 1: Import OneDrive Package
First, import the ballerinax/microsoft.onedrive module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};
```
### Step 3: Create OneDrive client
```ballerina
onedrive:Client driveClient = check new (config);
```
### Step 4: Upload a file
```ballerina
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
```
## Download a file from OneDrive
### Step 1: Import OneDrive Package
First, import the ballerinax/microsoft.onedrive module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};
```
### Step 3: Create OneDrive client
```ballerina
onedrive:Client driveClient = check new (config);
```
### Step 4: Download a file
```ballerina
    string filePath = "<PATH_FILE_TO_BE_DOWNLOADED>";
    
    onedrive:File|onedrive:Error itemResponse = driveClient->downloadFileByPath(filePath);
    if (itemResponse is onedrive:File) {
        byte[] content = let var item = itemResponse?.content in item is byte[] ? item : [];
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", content);
        log:printInfo("Success!");
    } else {
        log:printError(itemResponse.message());
    }
``` 
### [You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/onedrive/samples)
