## Overview
Ballerina connector for Microsoft OneDrive connects to the OneDrive file storage API in Microsoft Graph v1.0 via the 
Ballerina language. The connector allows you to programmatically perform basic drive functionalities such as file 
upload, download. It also allows you to share files and folders stored on Microsoft OneDrive.

This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) v1.0 and allows performing functions only on behalf of the currently signed-in user. 
## Configuring the connector
### Prerequisites
- A Microsoft 365 Personal account.
- An Azure account with an active subscription to register an application in the Azure portal.

### Obtaining tokens
Follow these steps to register your application and obtain the required tokens

**Step 1:** Register a new application in your Azure AD tenant

Follow this procedure to register your application and get the Application (client) ID:

   1. On the Application registrations page, click **New registration** and enter an appropriate display name for your application.
   2. In the **Supported account types** section, select **Accounts in any organizational directory (Any Azure AD directory - Multi-tenant) and personal Microsoft accounts (e.g., Skype, Xbox, Outlook.com)** or **Personal Microsoft accounts only**. 
   3. Provide a **Redirect URI** if necessary.
   4. Click **Register**. 

   5. Copy the Application (client) ID to a text file to use as the value of `<MS_CLIENT_ID>`, which is the unique identifier for your application.

**Step 2:** Create a new client secret

Follow this procedure to get the client secret for your application:

   1. Under **Manage**, click **Certificates & secrets**.
   2. In the **Client secrets** section, click **New client secret**.
   3. Enter an appropriate description and expiration date for the new client secret.
   4. Click **Add**.
   5. Copy the client secret to a text file to use as the value of `<MS_CLIENT_SECRET>`.


**Step 3:** Add scopes and permission

In an OpenID Connect or OAuth 2.0 authorization request, an application can request necessary permission using the scope query parameter. When it comes to Microsoft resources, some of the high-privilege admin-restricted permissions require an organization's administrator consent on behalf of organization users.<br/>
If you require such permission, be sure to request and get the appropriate permission.
   

**Step 4:** Obtain the access token and refresh token

Follow this procedure to get the access token, and refresh token:

   1. In the Overview of the application, click the **Endpoints** tab to view its authorization endpoint and token endpoint.
   2. Copy the **OAuth 2.0 token endpoint (v2)** value to a text file to use as the value of `<MS_REFRESH_URL>`.
   3. In a new browser, enter the URL as follows and replace `<MS_CLIENT_ID>` with the application ID you obtained in Step 1.

       ```
       https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=<MS_CLIENT_ID>&response_type=code&redirect_uri=https://oauth.pstmn.io/v1/browser-callback&response_mode=query&scope=openid offline_access <SPACE_SEPARATED_LIST_OF_SCOPES>
       ```
    
      This prompts for the username and password to sign in to the Azure Portal application.

   4. Enter the username and password. This takes you to a URL as follows:
        ```
        https://login.microsoftonline.com/common/oauth2/nativeclient?code=M95780001-0fb3-d138-6aa2-0be59d402f32
        ```
   5. Copy the code parameter (here it is M95780001-0fb3-d138-6aa2-0be59d402f32) to a text file to use as the value of `<MS_REFRESH_URL>` in the project configuration file.
   6. In a new terminal enter the following cURL command: 
      **Note**: Be sure to replace `<MS_CODE>`, `<MS_CLIENT_ID>`, and `<MS_CLIENT_SECRET>` with appropriate values you obtained in the steps above. 
      
        ```
        curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<MS_CLIENT_ID>&client_secret=<MS_CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&code=<MS_CODE>&scope=openid offline_access <SPACE_SEPARATED_LIST_OF_SCOPES>" https://login.microsoftonline.com/common/oauth2/v2.0/token

        ```
      The cURL command results in a response as follows with the values for `<MS_ACCESS_TOKEN>` and `<MS_REFRESH_TOKEN>`


        ```
        {
            "token_type": "Bearer",
            "scope": "openid <LIST_OF_PERMISSIONS>",
            "expires_in": 3600,
            "ext_expires_in": 3600,
            "access_token": "<MS_ACCESS_TOKEN>",
            "refresh_token": "<MS_REFRESH_TOKEN>",
            "id_token": "<ID_TOKEN>"
        }
        ```
        Copy the values of `<MS_ACCESS_TOKEN>` and `<MS_REFRESH_TOKEN>` to a text file to use in the project configuration file.
        
For more information on OAuth2 tokens, see [Register an application with the Microsoft identity platform](https://docs.microsoft.com/en-us/graph/auth-register-app-v2) and [OAuth 2.0 and OpenID Connect protocols on the Microsoft identity platform](https://docs.microsoft.com/en-au/azure/active-directory/develop/active-directory-v2-protocols#endpoints)<br/>

## Add the project configuration file

Follow this procedure:

1. Create a file named `config.toml` under the root path of the project structure.
2. Add the following configuration to the file:
  **Note**: Replace the placeholders with appropriate values you obtained by following the steps under [Obtain tokens](#obtain-tokens).


#### config.toml
```ballerina
[ballerinax.microsoft.onedrive]
refreshUrl = <MS_REFRESH_URL>
refreshToken = <MS_REFRESH_TOKEN>
clientId = <MS_CLIENT_ID>
clientSecret = <MS_CLIENT_SECRET>
```

# Quickstart

This section walks you through step-by-step instructions on how you can use the connector to perform various actions.

## Create a folder in OneDrive
### Step 1: Import the OneDrive package
Import the `ballerinax/microsoft.onedrive` module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2: Configure a connection to an existing Azure AD application
To make the connection, use the OAuth2 refresh token grant configuration as follows:
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
    }
};
```
### Step 3: Create a folder
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

## Upload a file to OneDrive
### Step 1: Import the OneDrive package
Import the `ballerinax/microsoft.onedrive` module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2: Configure the connection to an existing Azure AD application
To make the connection, use the OAuth2 refresh token grant configuration as follows:
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
    }
};
```
### Step 3: Create a OneDrive client
To create a OneDrive client, use the following line of code:
```ballerina
onedrive:Client driveClient = check new (config);
```
### Step 4: Upload a file
To upload a file, use the following code block:
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
### Step 1: Import the OneDrive package
Import the `ballerinax/microsoft.onedrive` module into the Ballerina project.
```ballerina
import ballerinax/microsoft.onedrive;
```
### Step 2: Configure the connection to an existing Azure AD application
To make the connection, use the OAuth2 refresh token grant configuration as follows:
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
    }
};
```
### Step 3: Create a OneDrive client
To create a OneDrive client, use the following line of code:
```ballerina
onedrive:Client driveClient = check new (config);
```
### Step 4: Download a file
To download a file, use the following code block:
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
