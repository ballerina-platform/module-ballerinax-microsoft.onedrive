# Examples

The `ballerinax/microsoft.onedrive` connector provides practical examples illustrating usage in various scenarios.

1. [Upload File](https://github.com/ballerina-platform/module-ballerinax-microsoft.onedrive/tree/master/examples/upload-file) - This example demonstrates how to use the Ballerina Microsoft OneDrive connector to upload a file from your local system to your OneDrive account.

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


## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
