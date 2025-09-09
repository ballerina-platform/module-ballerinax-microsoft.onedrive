# Upload File to Microsoft OneDrive

This example demonstrates how to upload files to OneDrive. The Ballerina programme retrives Drive Id, creates an "Upload" folder and upload a file to the said folder

## Prerequisites

### 1. Setup OneDrive API

Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/microsoft.onedrive/latest#setup-guide) for necessary credentials (client ID, secret, tokens).

### 2. Configuration

Configure OneDrive API credentials in `Config.toml` in the example directory:

```toml
refreshToken="<Refresh Token>"
clientId="<Client Id>"
clientSecret="<Client Secret>"
```

## Run the Example

Execute the following command to run the example:

```bash
bal run
```

Check the results in the One Drive.
