# Ballerina Microsoft OneDrive connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.onedrive.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/microsoft.onedrive.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%microsoft.onedrive)

## Overview

[Microsoft OneDrive](https://central.ballerina.io/ballerinax/microsoft.onedrive/latest) is a cloud-based file storage service provided by Microsoft, allowing users and organizations to store, share, and manage files securely online.

The `ballerinax/microsoft.onedrive` package offers APIs to connect and interact with OneDrive API endpoints, specifically based on [Microsoft Graph v1.0](https://learn.microsoft.com/en-us/graph/overview). This package enables developers to perform operations such as uploading, downloading, and sharing files and folders on OneDrive using the Ballerina language.

## Setup guide

### Step 1. Register the application

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/).
   
2. Go to **App registrations** > **New registration**.

   ![New Registration](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/1-App-registrations.png)

3. Enter a display name for your application.
   
   ![Register Application](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/2-Register-application.png)

4. Select who can use the application in the **Supported account types** section.
   
5. Leave **Redirect URI** blank for now (you will configure it later).
   
6. Click **Register** to complete the initial app registration.
   
7. After registration, note the **Application (client) ID** from the Overview pane.

   ![Application Overview](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/3-Application-details.png)


### Step 2. Configure platform settings

1. Under **Manage**, select **Authentication**.
   
2. Under **Platform configurations**, click **Add a platform**.
   
3. Select the **Web** tile.
   
4. Set the **Redirect URI** to `http://localhost`.
   
   ![Configure Web](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/4-Configure-web.png)
   
5. Click **Configure** to save the platform configuration.

### Step 3. Add credentials

1. Go to **Certificates & secrets** > **Client secrets** > **New client secret**.
   
   ![Add Secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/5-Add-secret.png)

2. Add a description for your client secret.
   
   ![Add Description](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/6-Give-description.png)

3. Select an expiration period or specify a custom lifetime.
   
4. Click **Add**.
   
5. **Copy and save the secret value** for use in your client application code. You will not be able to view it again after leaving the page.

      ![Save Secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/7-Note-down-secret.png)

### Step 4. Get the Auth Tokens

1. In your browser, enter the following URL (replace `<client-id>` with your actual client ID):

   ```
   https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=<client-id>&scope=offline_access files.read files.read.all files.readwrite files.readwrite.all&response_type=code&redirect_uri=http://localhost
   ```

   **Query parameter details:**

   | Parameter        | Description |
   |------------------|-------------|
   | `client_id`      | The Application (client) ID from your Azure app registration. |
   | `scope`          | The permissions your app is requesting. For OneDrive, these include:<br>- `offline_access`: Allows your app to receive refresh tokens for long-lived access.<br>- `files.read`: Read files the user can access.<br>- `files.read.all`: Read all files the user can access, including those shared with them.<br>- `files.readwrite`: Read and write files the user can access.<br>- `files.readwrite.all`: Read and write all files the user can access, including those shared with them. |
   | `response_type`  | Set to `code` to request an authorization code for OAuth2. |
   | `redirect_uri`   | The URI to redirect to after authentication. Must match the URI configured in your Azure app registration (e.g., `http://localhost`). |

2. Grant access to the application and click **Accept**.
   
   ![Give Access](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.onedrive/master/docs/setup/8-Give-access.png)

3. After authentication, you will be redirected to a URL like:
   ```
   http://localhost/?code=<auth-code>
   ```
   Copy the authorization code from the URL.

4. Exchange the authorization code for access and refresh tokens by sending the following request:

   ```
   curl -X POST https://login.microsoftonline.com/common/oauth2/v2.0/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=<client-id>&client_secret=<client-secret>&redirect_uri=http://localhost&code=<auth-code>&grant_type=authorization_code"
   ```

   The tokens will be returned in the response.

## Quickstart

To use the `microsoft.onedrive` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the module

Import the `microsoft.onedrive` module.

```ballerina
import ballerinax/microsoft.onedrive;
```

### Step 2: Instantiate a new connector

Create a `onedrive:ConnectionConfig` with the obtained OAuth2.0 tokens and initialize the connector with it.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

onedrive:Client onedrive = check new (
    config = {
        auth: {
            refreshToken,
            clientId,
            clientSecret,
            scopes: ["Files.Read", "Files.Read.All", "Files.ReadWrite", "Files.ReadWrite.All"]
        }
    }
);
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### See all the drives available

```ballerina
onedrive:DriveCollectionResponse driveItems = check oneDriveClient->listDrive();
```

## Examples

The `microsoft.onedrive` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-microsoft.onedrive/tree/master/examples/), covering the following use cases:

1. [Upload File](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/examples/upload-file) - This example demonstrates how to use the Ballerina Microsoft OneDrive connector to upload a file from your local system to your OneDrive account.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`microsoft.onedrive` package](https://central.ballerina.io/ballerinax/microsoft.onedrive/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
