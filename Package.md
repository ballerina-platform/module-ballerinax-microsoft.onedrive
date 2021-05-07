Ballerina Connector For Microsoft OneDrive
===================

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-onedrive/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.onedrive.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-onedrive/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Connects to Microsoft OneDrive using Ballerina.

- [Microsoft OneDrive Connecter](#markdown-navigation)
    - [Introduction](#introduction)
        - [What is Microsoft OneDrive](#what-is-microsoft-onedrive?)
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
service and synchronization service operated by Microsoft as part of its web version of Office. It provides 5GB of space 
offered for free to anyone with a Microsoft account. OneDrive’s starter tier allows for storage and document editing and 
collaboration via Office Online. For Windows 10 users, OneDrive is embedded in the operating system by default. OneDrive 
allows users to save files, photos and other documents across multiple devices. A user can also save their files in 
OneDrive and have it automatically sync on other devices. This means someone can access and work on the same document in 
multiple locations. OneDrive provides relatively easy access to cloud storage space, allowing options to share content
with others. OneDrive integrates with Microsoft Office so users can access Word, Excel and Powerpoint documents from 
OneDrive. It doesn’t require a download and should already be a part of Windows 10. 

<p align="center">
<img src="./docs/images/One_Drive.png?raw=true" alt="One Drive"/>
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
- Micrsoft Account
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
    directory - Multitenant) and personal Microsoft accounts (e.g., Skype, Xbox, Outlook.com). Click Register to 
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
|                                 | Version               |
|---------------------------------|-----------------------|
| Ballerina Language Version      | **Swan Lake Alpha 5** |
| Microsoft Graph API Version     | **v1.0**              |
| Java Development Kit (JDK)      | 11                    |

## Limitations
- Connector only allows to perform functions onbehalf of the currently logged in user.
- Only the operations which are supported in personal Microsoft account is supported.

# Quickstart(s)
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
    byte[] byteArray = checkpanic io:fileReadBytes(<PATH_TO_FILE>);
    string fileNameForNewUploadById = "<NEW_FILE_NAME.extention>";
    string parentFolderId = "<PARENT_FOLDER_ID>";

    onedrive:DriveItem|onedrive:Error itemInfo = driveClient->uploadDriveItemToFolderById(parentFolderId, 
        fileNameForNewUploadById, byteArray);
    if (itemInfo is onedrive:DriveItem) {
        io:println("Uploaded item " + itemInfo?.id.toString());
    } else {
        io:println(itemInfo.message());
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
    string fileId = "<ID_OF_FILE_TO_DOWNLOAD>";

    byte[]|onedrive:Error itemResponse = driveClient->downloadFileById(fileId);
    if (itemResponse is byte[]) {
        io:Error? result = io:fileWriteBytes("./files/downloadedFile", itemResponse);
    } else {
        io:println(itemResponse.message());
    }
```
# Samples

## Get DriveItem metadata
Retrieve the metadata for a DriveItem in a Drive by item ID or file syatem path (relative path). 

## Get recent DriveItems
Lists a set of items that have been recently used by the `signed in user`. This will include items that are in the 
user's drive as well as the items they have access to from other drives.

## Get DriveItems shared with me
Retrieve a collection of `DriveItem` resources that have been shared with the `signed in user` of the OneDrive.

## Create new folders in OneDrive
Create a new folder in a Drive with a specified parent item, referred with the parent folder's ID or file syatem path 
(relative path).

## Update a DriveItem
Update the metadata for a DriveItem in a Drive referring by item ID or file syatem path (relative path).

## Delete a DriveItem
Delete a DriveItem in a Drive by using it's item ID or file syatem path (relative path).

## Restore DriveItem
Restore a driveItem that has been deleted and is currently in the recycle bin.

## Copy a DriveItem
Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same location 
with a new name.

## Download file
Download the contents of the primary stream (file) of a DriveItem using item ID or it's file syatem path (relative path). 
**NOTE:** Only driveItems with the file property can be downloaded.

## Upload a small file to a certain location in OneDrive
Upload a new file to the Drive. This method only supports files up to 4MB in size.

## Replace file
Update the contents of an existing file in the Drive. This method only supports files up to 4MB in size. Here, the type 
of the file should be the same type as the file we replace with.

## Upload a large file to a certain location in OneDrive
Upload files up to the maximum file size. **NOTE:** Maximum bytes in any given request is less than 60 MiB.

## Search DriveItems
Search the hierarchy of items for items matching a query.

## Get a sharable link for a DriveItem
Create a new sharing link if the specified link type doesn't already exist for the calling application. If a sharing 
link of the specified type already exists for the app, the existing sharing link will be returned.

## Get metadata for a shared DriveItem
Access a shared DriveItem by using sharing URL.

## Send sharing invitation via emails
Sends a sharing invitation for a DriveItem. A sharing invitation provides permissions to the recipients and optionally 
sends them an email with a sharing link.


# Building from the Source
## Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed 
        JDK.

2. Download and install [Ballerina SLP8](https://ballerina.io/). 

## Building the Source
Execute the commands below to build from the source after installing Ballerina SLP8 version.

1. To build the library:
```shell script
    ballerina build
```

2. To build the module without the tests:
```shell script
    ballerina build --skip-tests
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