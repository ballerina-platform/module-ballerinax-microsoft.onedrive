Ballerina Connector For Microsoft OneDrive
===================

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-onedrive/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.onedrive.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-onedrive/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Connects to Microsoft OneDrive using Ballerina.

- [Microsoft OneDrive Connector]
    - [Introduction](#introduction)
        - [What is Microsoft OneDrive](#what-is-microsoft-onedrive)
        - [Key features of Microsoft OneDrive](#key-features-of-microsoft-onedrive)
        - [Connector Overview](#connector-overview)
    - [Prerequisites](#prerequisites)
        - [Obtaining tokens](#obtaining-tokens)
        - [Add project configurations file](#add-project-configurations-file)
    - [Supported versions & limitations](#supported-versions-&-limitations)
    - [Quickstarts](#quickstarts)
    - [Samples](#samples)
    - [Building from the Source](#building-from-the-source)
    - [Contributing to Ballerina](#contributing-to-ballerina)
    - [Code of Conduct](#code-of-conduct)
    - [Useful Links](#useful-links)

# Introduction
## What is Microsoft OneDrive?
[Microsoft OneDrive](https://www.microsoft.com/en-us/microsoft-365/onedrive/online-cloud-storage) is a file hosting 
service and synchronization service operated by Microsoft as part of its web version of Office. It provides 5 GB of space 
offered for free to anyone with a Microsoft account. OneDrive’s starter tier allows for storage and document editing and 
collaboration via Office Online. For Windows 10 users, OneDrive is embedded in the operating system by default. OneDrive 
allows users to save files, photos and other documents across multiple devices. A user can also save their files in 
OneDrive and have it automatically sync on other devices. This means someone can access and work on the same document in 
multiple locations. OneDrive provides relatively easy access to cloud storage space, allowing options to share content
with others. OneDrive integrates with Microsoft Office so users can access Word, Excel and Powerpoint documents from 
OneDrive. It doesn’t require a download and should already be a part of Windows 10. 

<p align="center">
<img src="./docs/images/One_Drive.png?raw=true" alt="One Drive" width="500"/>
</p>

## Key features of Microsoft OneDrive
- Unlimited file access, anytime  
- Renders files available from anywhere for collaboration
- Organisational platform for files  
- Free-up device storage  
- Sharable content across teams, large or small  
- Customisable sync experience (for admin) 
- Securely store files and information  
- Supports multimedia  
- Tightly integrate with other Microsoft products (including 365)  

## Connector Overview
Ballerina connector for Microsoft OneDrive is connecting to OneDrive file storage API in Microsoft Graph v1.0 via Ballerina 
language easily. It provides capability to perform basic drive functionalities including as Uploading, Downloading, 
Sharing files and folders which have been stored on Microsoft OneDrive programmatically. 

The connector is developed on top of Microsoft Graph is a REST web API that empowers you to access Microsoft Cloud 
service resources. This version of the connector only supports the access to the resources and information of a specific 
account (currently logged in user).

# Prerequisites
- Microsoft Account
- Access to Azure Portal
- Java 11 installed - Java Development Kit (JDK) with version 11 is required
- [Ballerina SL Alpha 5](https://ballerina.io/learn/user-guide/getting-started/setting-up-ballerina/installation-options/) installed 
    - Ballerina Swan Lake Alpha 5 is required

## Obtaining tokens
- Create an account in OneDrive
- Sign into Azure Portal - App Registrations. (You can use your personal, work or school account to register the app)

- Obtaining OAuth2 credentials <br/>
    To get an access token you need to register your app with microsoft identity platform via Azure Portal. <br/>
    **(The access token contains information about your app and the permissions it has for the resources and APIs 
    available through Microsoft Graph. To get an access token, your app must be registered with the Microsoft 
    identity platform and be authorized by either a user or an administrator for access to the Microsoft Graph 
    resources it needs.)**

    Before your app can get a token from the Microsoft identity platform, it must be registered in the Azure portal. 
    Registration integrates your app with the Microsoft identity platform and establishes the information that it 
    uses to get tokens
    1. App Id
    2. Redirect URL
    3. App Secret <br/>

    **Step 1:** Register a new application in your Azure AD tenant.<br/>
    - In the App registrations page, click **New registration** and enter a meaningful name in the name field.
    - In the **Supported account types** section, select Accounts in any organizational directory (Any Azure AD 
    directory - Multi-tenant) and personal Microsoft accounts (e.g., Skype, Xbox, Outlook.com). Click Register to 
    create the application.
    - Provide a **Redirect URI** if necessary.

        ![Obtaining Credentials Step 1](docs/images/s1.png)
    - Copy the Application (client) ID to fill `<MS_CLIENT_ID>`. This is the unique identifier for your app.

        ![Obtaining Credentials Step 1](docs/images/s2.png)

    **Step 2:** Create a new client secret.<br/>
    - Under **Certificates & Secrets**, create a new client secret to fill `<MS_CLIENT_SECRET>`. This requires providing 
    a description and a period of expiry. Next, click Add.

        ![Obtaining Credentials Step 2](docs/images/s3.png)

    **Step 3:** Add necessary scopes/permissions.<br/>
    - In an OpenID Connect or OAuth 2.0 authorization request, an app can request the permissions it needs by using the 
    scope query parameter.
    - Some high-privilege permissions in Microsoft resources can be set to admin-restricted. So, if we want to access 
    such kind of resources, an organization's administrator must consent to those scopes on behalf of the organization's 
    users.
    
        ![Obtaining Credentials Step 3](docs/images/s4.png)

    **Step 4:** Obtain the authorization endpoint and token endpoint by opening the `Endpoints` tab in the application 
    overview. <br/>
    - The **OAuth 2.0 token endpoint (v2)** can be used as the value for `<MS_REFRESH_URL>`

        ![Obtaining Credentials Step 4](docs/images/s5.png)

    - In a new browser, enter the below URL by replacing the <MS_CLIENT_ID> with the application ID.

        ```
        https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=<MS_CLIENT_ID>&response_type=code&redirect_uri=https://oauth.pstmn.io/v1/browser-callback&response_mode=query&scope=openid offline_access https://graph.microsoft.com/Files.ReadWrite.All
        ```
    
    - This will prompt you to enter the username and password for signing into the Azure Portal App.
    - Once the username and password pair is successfully entered, this will give a URL as follows on the browser address 
    bar.
        ```
        https://login.microsoftonline.com/common/oauth2/nativeclient?code=M95780001-0fb3-d138-6aa2-0be59d402f32
        ```
    - Copy the code parameter (M95780001-0fb3-d138-6aa2-0be59d402f32 in the above example) and in a new terminal, enter 
    the following cURL command by replacing the <MS_CODE> with the code received from the above step. The <MS_CLIENT_ID> 
    and <MS_CLIENT_SECRET> parameters are the same as above.
        ```
        curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<MS_CLIENT_ID>&client_secret=<MS_CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&code=<MS_CODE>&scope=Files.ReadWrite openid User.Read Mail.Send Mail.ReadWrite offline_access" https://login.microsoftonline.com/common/oauth2/v2.0/token
        ```
        
    - The above cURL command should result in a response as follows.
        ```
        {
            "token_type": "Bearer",
            "scope": "Files.ReadWrite openid User.Read Mail.Send Mail.ReadWrite",
            "expires_in": 3600,
            "ext_expires_in": 3600,
            "access_token": "<MS_ACCESS_TOKEN>",
            "refresh_token": "<MS_REFRESH_TOKEN>",
            "id_token": "<ID_TOKEN>"
        }
        ```
    **More information about OAuth2 tokens can be found here:** <br/>
    https://docs.microsoft.com/en-us/graph/auth-register-app-v2 <br/>
    https://docs.microsoft.com/en-au/azure/active-directory/develop/active-directory-v2-protocols#endpoints <br/>

## Add project configurations file
Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the tokens obtained in the previous steps to the `Config.toml` file.

#### Config.toml
```ballerina
[ballerinax.microsoft.onedrive]
refreshUrl = <MS_REFRESH_URL>
refreshToken = <MS_REFRESH_TOKEN>
clientId = <MS_CLIENT_ID>
clientSecret = <MS_CLIENT_SECRET>
scopes = [<MS_NECESSARY_SCOPES>]
```
# Supported versions & limitations
## Supported Versions
|                                                                                    | Version               |
|------------------------------------------------------------------------------------|-----------------------|
| Ballerina Language Version                                                         | **Swan Lake Beta 1** |
| [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) Version     | **v1.0**              |
| Java Development Kit (JDK)                                                         | 11                    |

## Limitations
- Connector only allows to perform functions behalf of the currently logged in user.
- Only the operations which are supported in personal Microsoft account is supported.

# Quickstart(s)

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
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
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

    onedrive:DriveItem|onedrive:Error driveItem = driveClient->createFolderById(parentID, item);

    if (driveItem is onedrive:DriveItem) {
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
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
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

    onedrive:DriveItem|onedrive:Error itemInfo = driveClient->uploadDriveItemToFolderByPath(parentFolderPath, 
        fileNameNewForNewUploadByPath, byteArray, mediaType);
    if (itemInfo is onedrive:DriveItem) {
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
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
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
# Samples
## Get DriveItem metadata
Retrieve the metadata for a DriveItem in a Drive by item ID or file system path (relative path). 

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_item_metadata_by_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_item_metadata_by_path.bal 

Notes : <br/>
This operation supports several OData query parameters as well as normal query parameters.
* **$expand** 
* **$select**
* **includeDeletedItems=true** - Query parameter to return deleted items. This query parameter is only valid when targeting a driveItem by ID, and otherwise will be ignored.

Sample with query parameters is available here: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_item_metadata_by_id_query_params.bal

## Get recent DriveItems
Lists a set of items that have been recently used by the `signed in user`. This will include items that are in the 
user's drive as well as the items they have access to from other drives.

Sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_recent_items.bal

## Get DriveItems shared with me
Retrieve a collection of `DriveItem` resources that have been shared with the `signed in user` of the OneDrive.

Sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_shared_items.bal

## Create new folders in OneDrive
Create a new folder in a Drive with a specified parent item, referred with the parent folder's ID or file system path 
(relative path).

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/create_folder_by_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/create_folder_by_path.bal

## Update a DriveItem
Update the metadata for a DriveItem in a Drive referring by item ID or file system path (relative path).

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/update_drive_item_by_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/update_drive_item_by_path.bal

**Notes:** <br/>
* Item update does not work when item is open in browser (On editing view)
https://stackoverflow.com/questions/50057662/not-able-to-update-file-stream-through-microsoft-graph-sdk-when-file-is-open-in

* The set of exact fields which can be updated is not provided in the docs. 
If we try to update facets which are not related to the current resource (eg: if the resource is a file and we send folder facet it gives an error) error occurs.

## Delete a DriveItem
Delete a DriveItem in a Drive by using it's item ID or file system path (relative path).

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/delete_drive_item.by_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/delete_drive_item.by_path.bal

## Restore DriveItem
Restore a DriveItem that has been deleted and is currently in the recycle bin.

Sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/restore_drive_item.bal

## Copy a DriveItem
Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same location 
with a new name.

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/copy_drive_item_by_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/copy_drive_item_by_path.bal

## Download file
Download the contents of the primary stream (file) of a DriveItem using item ID or it's file system path (relative path). 

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/download_file_by_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/download_file_by_path.bal

**Notes:** <br/> 
* Only DriveItems with the file property can be downloaded.

## Upload a small file to a certain location in OneDrive
Upload a new file to the Drive.

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/upload_file_to_parent_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/upload_file_to_parent_path.bal

**Notes:** <br/>
* This method only supports files up to 4MB in size.

## Replace file
Update the contents of an existing file in the Drive.

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/replace_file_using_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/replace_file_using_path.bal

**Notes:** <br/>
* The file used for replacing must be of the same media type as the file which will be replaced.
* This method only supports files up to 4MB in size.

## Upload a large file to a certain location in OneDrive
Upload files up to the maximum file size. 

Sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/upload_large_file.bal

**Notes:** <br/> 
* Maximum bytes in any given request should be less than 60 MiB.
* If the file is fragmented into into multiple byte ranges, the size of each byte range MUST be a multiple of 320 KiB 
(327,680 bytes). You can use the constant `ondedrive:DEFAULT_FRAGMENT_SIZE` to easily obtain a multiple of 320 KiB.

## Search DriveItems
Search the hierarchy of items for items matching a query. You can search within a folder hierarchy, a whole drive, or 
files shared with the current user.

Sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/search_drive_items.bal

**Notes:** <br/>
* Supports the **$expand**, **$select**, **$skipToken**, **$top**, and **$orderby** OData query parameters to customize 
the response.
* You can use the **$top** query parameter to specify the number of items in the page.
* Find more on Odata query parameters here: https://docs.microsoft.com/en-us/onedrive/developer/rest-api/concepts/optional-query-parameters?view=odsp-graph-online

## Get a sharable link for a DriveItem
Create a new sharing link if the specified link type doesn't already exist for the calling application. If a sharing 
link of the specified type already exists for the app, the existing sharing link will be returned.

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_sharable_link_from_id.bal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_sharable_link_from_path.bal

## Get metadata for a shared DriveItem
Access a shared DriveItem by using sharing URL.

Sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/get_shared_drive_item.bal

## Send sharing invitation via emails
Sends a sharing invitation for a DriveItem. A sharing invitation provides permissions to the recipients and optionally 
sends them an email with a sharing link.

ID based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/send_sharing_invitation_by_id.balal

Path based addressing sample is available at: https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/samples/send_sharing_invitation_by_path.bal

**Notes:** <br/>
* OneDrive personal accounts cannot create or modify permissions on the root DriveItem.

# Building from the Source
## Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed 
        JDK.

2. Download and install [Ballerina SLP8](https://ballerina.io/). 

## Building the Source
Execute the commands below to build from the source after installing Ballerina SL Alpha 5 version.

1. To build the library:
```shell script
    bal build
```

2. To build the module without the tests:
```shell script
    ball build --skip-tests
```
# Contributing to Ballerina
As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/main/CONTRIBUTING.md).

# Code of Conduct
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

# Useful Links
* Discuss about code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
