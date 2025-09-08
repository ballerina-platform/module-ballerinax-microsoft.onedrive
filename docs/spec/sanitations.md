_Author_:  @niveathika \
_Created_: 01/09/2025 \
_Updated_: 01/09/2025 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document outlines the modifications made to the official OpenAPI specification from the [Microsoft Graph API](https://github.com/microsoftgraph/msgraph-metadata/blob/master/openapi/v1.0/openapi.yaml) to focus specifically on OneDrive functionality. The original specification is extensive, covering APIs for all Microsoft 365 resources. For product-specific use cases, subsets of these APIs are typically extracted and published. The OneDrive-focused OpenAPI spec used here was sourced from [msgraph-sdk-powershell](https://github.com/microsoftgraph/msgraph-sdk-powershell/blob/dev/openApiDocs/v1.0/Files.yml) and then sanitized to improve usability and address language limitations.
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. Removed `/users`, `/groups`, and `/sites` endpoints. In Microsoft Graph, OneDrive functionality is accessible from several root resources, not just under these subgroups. For details, see [Microsoft Graph root resources](https://learn.microsoft.com/en-us/onedrive/developer/rest-api/?view=odsp-graph-online#microsoft-graph-root-resources).
2. Reduced the API set from over 200 endpoints to approximately 70, focusing on those most relevant for integration and omitting meta-level or rarely used APIs. For full list, see [MS OneDrive Endpoints](https://docs.google.com/spreadsheets/d/1_CVic4I9X7vZAMPK6ooVwiG-AJMXA0zgVb3Mly27it4/edit?gid=1884773845#gid=1884773845)
3. Cleaned up and standardized operation IDs using AI-assisted naming for better clarity and consistency.
4. Update 
    ```
    additionalProperties:
      type: object
    ```
    to
    ```
    additionalProperties: true
    ```
    Due to [OpenAPI generation incorrectly resolves additional properties, object when included in oneOf type](https://github.com/ballerina-platform/ballerina-library/issues/8205)
5. Add support to path based URLs

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.yaml -o ballerina --mode client --client-methods remote --license docs/license.txt
```
Note: The license year is hardcoded to 2025, change if necessary.
