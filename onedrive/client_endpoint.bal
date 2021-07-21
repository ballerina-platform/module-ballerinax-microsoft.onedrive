// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;
import ballerina/log;

# This is connecting to the Microsoft Graph RESTful web API that enables you to access Microsoft Cloud service resources.
# 
# + httpClient - the HTTP Client
@display {
    label: "Microsoft OneDrive Client", 
    iconPath: "MSOneDriveLogo.svg"
}
public isolated client class Client {
    final http:Client httpClient;
    final readonly & Configuration config;
    # Gets invoked to initialize the `connector`.
    # The connector initialization requires setting the API credentials. 
    # Create a [Microsoft 365 Work and School account](https://www.office.com/) 
    # and obtain tokens following [this guide](https://docs.microsoft.com/en-us/graph/auth-register-app-v2). Configure the Access token to 
    # have the [required permission](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis#add-a-scope).
    # 
    # + onedriveConfig - Configurations required to initialize the `Client` endpoint
    # + return - Error at failure of client initialization
    public isolated function init(Configuration onedriveConfig) returns error? {
        http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig = onedriveConfig.clientConfig;
        http:ClientSecureSocket? socketConfig = onedriveConfig?.secureSocketConfig;
        self.httpClient = check new (BASE_URL, {
            auth: clientConfig,
            secureSocket: socketConfig,
            cache: {
                enabled: false // Disabled caching for now due to NLP exception in getting the stream for downloads.
            },
            followRedirects: {enabled: true, maxCount: 5}
        });
        self.config = onedriveConfig.cloneReadOnly();
    }

    // ************************************* Operations on a Drive resource ********************************************
    // The Drive resource is the top-level object representing a user's OneDrive.

    # Lists a set of items that have been recently used by the `signed in user`. <br/>
    # This will include items that are in the user's drive as well as the items they have access to from other drives.
    # 
    # + return - An array of `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Get list of recent items"}
    remote isolated function getRecentItems() returns @display {label: "DriveItem List"} DriveItemData[]|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, RECENT_ITEMS]);
        return check getDriveItemArray(self.httpClient, path);
    }

    # Retrieves a collection of `DriveItemData` resources that have been shared with the `signed in user` of the OneDrive.
    # 
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - An array of `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Get list of items shared with me"}
    remote isolated function getItemsSharedWithMe(@display {label: "Optional Query Parameters"} 
                                                  string? queryParams = ()) returns 
                                                  @display {label: "DriveItem List"} DriveItemData[]|error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, SHARED_WITH_LOGGED_IN_USER], 
            queryParams);
        return check getDriveItemArray(self.httpClient, path);
    }

    // ************************************ Operations on a DriveItem resource *****************************************
    // The DriveItem resource represents a file, folder, or other item stored in OneDrive.
  
    # Creates a new folder in a Drive with a specified parent item, referred with the parent folder's ID.
    # 
    # + parentFolderId - The folder ID of the parent folder where, the new folder will be created
    # + folderMetadata - A record `onedrive:FolderMetadata` which contains the necessary data to create a folder
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Create new folder (ID based)"}
    remote isolated function createFolderById(@display {label: "Parent Folder ID"} string parentFolderId, 
                                              @display {label: "Additional Folder Data"} FolderMetadata folderMetadata) 
                                              returns DriveItemData|Error { 
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, parentFolderId, 
            CHILDREN_RESOURCES]);
        return check createFolder(self.httpClient, path, folderMetadata);
    }

    # Creates a new folder in a Drive with a specified parent item referred with the folder path.
    # 
    # + parentFolderPath - The folder path of the parent folder relative to the `root` of the respective Drive where, 
    #                      the new folder will be created
    #                    - **NOTE:** When you want to create a folder on root itself, you must give the relative path of the new folder only.
    # + folderMetadata - A record of type `FolderMetadata` which contains the necessary data to create a folder
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Create new folder (Path based)"}
    remote isolated function createFolderByPath(@display {label: "Parent Folder Path"} string parentFolderPath, 
                                                @display {label: "Additional Folder Data"} FolderMetadata folderMetadata) 
                                                returns DriveItemData|Error {
        string path = EMPTY_STRING;
        if (parentFolderPath == EMPTY_STRING || parentFolderPath == FORWARD_SLASH) {
            path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT, CHILDREN_RESOURCES]);
        } else {
            path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], parentFolderPath, 
                [CHILDREN_RESOURCES]);
        }
        return check createFolder(self.httpClient, path, folderMetadata);
    }

    # Retrieves the metadata for a DriveItem in a Drive by item ID.
    # 
    # + itemId - The ID of the DriveItem
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Get item metadata (ID based)"}
    remote isolated function getItemMetadataById(@display {label: "Item ID"} string itemId, 
                                                 @display {label: "Optional Query Parameters"} 
                                                 string? queryParams = ()) returns DriveItemData|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId], queryParams);
        return check getDriveItem(self.httpClient, path);
    }

    # Retrieves the metadata for a DriveItem in a Drive by file system path.
    # 
    # + itemPath - The file system path of the DriveItem. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Get item metadata (Path based)"}
    remote isolated function getItemMetadataByPath(@display {label: "Item Path Relative to Drive Root"} string itemPath, 
                                                   @display {label: "Optional Query Parameters"} 
                                                   string? queryParams = ()) returns DriveItemData|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [], queryParams);
        return check getDriveItem(self.httpClient, path);
    }

    # Updates the metadata for a DriveItem in a Drive referring by item ID.
    # 
    # + itemId - The ID of the DriveItem
    # + replacementData - A record `onedrive:DriveItem` which contains the values for properties that should be updated
    # + return - A record `onedrive:DriveItem` if sucess. Else `onedrive:Error`.
    @display {label: "Update item metadata (ID based)"}
    remote isolated function updateDriveItemById(@display {label: "Item ID"} string itemId, 
                                                 @display {label: "Replacement Item Data"} DriveItem replacementData)
                                                 returns DriveItemData|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId]);
        return updateDriveItem(self.httpClient, path, replacementData); 
    }

    # Updates the metadata for a DriveItem in a Drive by file system path.
    # 
    # + itemPath - The file system path of the DriveItem
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + replacementData - A record of type `DriveItem` which contains the values for properties that should be updated
    # + return - A record `onedrive:DriveItem` if sucess. Else `onedrive:Error`.
    @display {label: "Update item metadata (Path based)"}
    remote isolated function updateDriveItemByPath(@display {label: "Item Path Relative to Drive Root"} string itemPath, 
                                                   @display {label: "Replacement Item Data"} DriveItem replacementData)
                                                   returns DriveItemData|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath);
        return updateDriveItem(self.httpClient, path, replacementData); 
    }

    # Deletes a DriveItem in a Drive by using it's ID.
    # 
    # + itemId - The ID of the DriveItem
    # + return - `onedrive:Error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete drive item (ID based)"}
    remote isolated function deleteDriveItemById(@display {label: "Item ID"} string itemId) returns Error? {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId]);
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);
    }

    # Deletes a DriveItem in a Drive by using it's file system path.
    # 
    # + itemPath - The file system path of the DriveItem
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + return - `onedrive:Error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete drive item (Path based)"}
    remote isolated function deleteDriveItemByPath(@display {label: "Item Path Relative to Drive Root"} string itemPath) 
                                                   returns Error? {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath);
        http:Response response = check self.httpClient->delete(path);
        _ = check handleResponse(response);
    }

    # Restores a driveItem that has been deleted and is currently in the recycle bin. <br/> **NOTE:** This functionality is 
    # currently only available for OneDrive Personal.
    # 
    # + itemId - The ID of the DriveItem
    # + parentFolderId - The ID of the parent item the deleted item will be restored to
    # + name - The new name for the restored item
    #        - If this isn't provided, the same name will be used as the original.
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Restore drive item"}
    remote isolated function restoreDriveItem(@display {label: "Item ID"} string itemId, 
                                              @display {label: "Parent Folder ID"} string? parentFolderId = (),
                                              @display {label: "New File Name"} string? name = ())
                                              returns DriveItemData|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
            RESTORE_ACTION]);
        json restoreItemOptions = {};
        if (name is () && parentFolderId != ()) {
            restoreItemOptions = {
                                    parentReference : {
                                        id: parentFolderId
                                    }
                                 };
        } else if (name != () && parentFolderId != ()) {
            restoreItemOptions = {
                                    name: name,
                                    parentReference : {
                                        id: parentFolderId
                                    }
                                };
        } else if (name != () && parentFolderId is ()) {
            restoreItemOptions = {
                                    name: name
                                 };
        }
        http:Response response = check self.httpClient->post(path, restoreItemOptions);
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            return check convertToDriveItem(handledResponse);
        } else {
            return error PayloadValidationError(INVALID_RESPONSE);
        }
    }

    # Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same 
    # location with a new name.
    # 
    # + itemId - The ID of the DriveItem
    # + name - The new name for the copy
    #        - If this isn't provided, the same name will be used as the original.
    # + parentReference - A record `onedrive:ParentReference` that represents reference to the parent item the 
    #                     copy will be created in
    # + return - A `string` which represents the ID of the newly created copy if sucess. Else `onedrive:Error`.
    @display {label: "Copy drive item (ID based)"}
    remote isolated function copyDriveItemWithId(@display {label: "Item ID"} string itemId, 
                                                 @display {label: "New File Name"} string? name = (), 
                                                 @display {label: "Parent Item Data"} 
                                                 ParentReference? parentReference = ()) 
                                                 returns @display {label: "Item ID"} string|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, COPY_ACTION]);
        return check copyDriveItem(self.httpClient, path, parentReference, name);
    }

    # Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same 
    # location with a new name.
    # 
    # + itemPath - The file system path of the DriveItem  
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + name - The new name for the copy
    #        - If this isn't provided, the same name will be used as the original.
    # + parentReference - A record `onedrive:ParentReference` that represents reference to the parent item the 
    #                     copy will be created in.
    # + return - A `string` which represents the ID of the newly created copy if sucess. Else `onedrive:Error`.
    @display {label: "Copy drive item (Path based)"}
    remote isolated function copyDriveItemInPath(@display {label: "Item Path Relative to Drive Root"} string itemPath, 
                                                 @display {label: "New Name For Copy"} string? name = (), 
                                                 @display {label: "Parent Item Data"} 
                                                 ParentReference? parentReference = ()) 
                                                 returns @display {label: "Item ID"} string|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [COPY_ACTION]);
        return check copyDriveItem(self.httpClient, path, parentReference, name);
    }

    # Downloads the contents of the primary stream (file) of a DriveItem using item ID. <br/> **NOTE:** Only driveItems 
    # with the file property can be downloaded.
    # 
    # + itemId - The ID of the DriveItem
    # + formatToConvert - Specify the format the item's content should be downloaded as.
    # + return - A record `onedrive:File` if sucess. Else `onedrive:Error`.
    @display {label: "Download file (ID based)"}
    remote isolated function downloadFileById(@display {label: "Item ID"} string itemId, 
                                              @display {label: "Item Format Data"} FileFormat? formatToConvert = ()) 
                                              returns File|Error {
        string path = EMPTY_STRING;
        if (formatToConvert is ()) {
            path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
                CONTENT_OF_DRIVE_ITEM]);
        } else {
            path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
                CONTENT_OF_DRIVE_ITEM], string `format=${formatToConvert.toString()}`);
        }
        return check downloadDriveItem(self.httpClient, path);
    }

    # Downloads the contents of the primary stream (file) of a DriveItem using item path. <br/> **NOTE:** Only 
    # driveItems with the file property can be downloaded.
    # 
    # + itemPath - The file system path of the File
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    #            - **example:** Use the itempath as `/Documents/MyFile.xlsx` if MyFile.xlsx is located inside a folder called Docuements.
    # + formatToConvert - Specify the format the item's content should be downloaded as.
    # + return - A record `onedrive:File` if successful. Else `onedrive:Error`.
    @display {label: "Download file (Path based)"}
    remote isolated function downloadFileByPath(@display {label: "Item Path Relative to Drive Root"} string itemPath, 
                                                @display {label: "Item Format Data"} FileFormat? formatToConvert = ()) 
                                                returns File|Error {
        string path = EMPTY_STRING;
        if (formatToConvert is ()) {
            path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
                [CONTENT_OF_DRIVE_ITEM]);
        } else {
            path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
                [CONTENT_OF_DRIVE_ITEM], string `format=${formatToConvert.toString()}`);
        }
        return check downloadDriveItem(self.httpClient, path);
    }

    # Downloads the contents of the primary stream (file) of a DriveItem using download URL. <br/> **NOTE:** Only driveItems 
    # with the file property can be downloaded.
    # 
    # + downloadUrl - Download URL for a specific DriveItem
    # + partialContentOption - The value for the `Range` header to download a partial range of bytes from the file
    # + return - A record `onedrive:File` if successful. Else `onedrive:Error`.
    @display {label: "Download file by download URL"}
    remote isolated function downloadFileByDownloadUrl(@display {label: "Downloadable URL of File"} string downloadUrl, 
                                                       @display {label: "Byte Range for Partial Content"} 
                                                       ByteRange? partialContentOption = ()) returns File|Error {
        map<string> headerMap = {};
        if (partialContentOption != ()) {
            string partialRangeHeader = 
                string `bytes=${partialContentOption?.startByte.toString()}-${partialContentOption?.endByte.toString()}`;
            headerMap = {
                [RANGE]: partialRangeHeader
            };
        }
        return handleDownloadPrtialItem(downloadUrl, headerMap);
    }

    //********************* Functions for uploading and replacing the files using steam of bytes ***********************
    // # Upload a new file to the Drive. This method only supports files up to 4MB in size.
    // # 
    // # + parentFolderId - The folder ID of the parent folder where, the new file will be uploaded
    // # + fileName - The name of the new file
    // # + binaryStream - An stream of `byte[]` that represents a binary stream of the file to be uploaded
    // # + mimeType - The media type of the uploading file
    // # + return - A record of type `DriveItemData` if success. Else `Error`.
    // @display {label: "Upload file (ID based)"}
    // remote isolated function uploadFileToFolderById(@display {label: "Parent Folder ID"} string parentFolderId, 
    //                                                 @display {label: "File Name"} string fileName, 
    //                                                 @display {label: "Stream of bytes to upload"} 
    //                                                 stream<byte[],io:Error?> binaryStream, 
    //                                                 @display {label: "Mime Type"} string mimeType) returns 
    //                                                 @display {label: "DriveItem Metadata"} DriveItemData|Error {
    //     string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, parentFolderId], 
    //         string `/${fileName}`, [CONTENT_OF_DRIVE_ITEM]);
    //     return uploadDriveItem(self.httpClient, path, binaryStream, mimeType); 
    // }

    // # Upload a new file to the Drive. This method only supports files up to 4MB in size.
    // # 
    // # + parentFolderPath - The folder path of the parent folder relative to the `root` of the respective Drive where, 
    // #                      the new folder will be created.
    // #                      **NOTE:** When you want to create a folder on root itself, you must give the relative path 
    // #                      of the new folder only.
    // # + fileName - The name of the new file
    // # + binaryStream - An stream of `byte[]` that represents a binary stream of the file to be uploaded
    // # + mimeType - The media type of the uploading file
    // # + return - A record of type `DriveItemData` if success. Else `Error`.
    // @display {label: "Upload file (Path based)"}
    // remote isolated function uploadFileToFolderByPath(@display {label: "Parent Folder Path"} 
    //                                                   string parentFolderPath, 
    //                                                   @display {label: "File Name"} string fileName, 
    //                                                   @display {label: "Stream of bytes to upload"} 
    //                                                   stream<byte[],io:Error?> binaryStream, 
    //                                                   @display {label: "Mime Type"} string mimeType) returns 
    //                                                   @display {label: "DriveItem Metadata"} DriveItemData|Error {
    //     string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], 
    //         string `${parentFolderPath}/${fileName}`, [CONTENT_OF_DRIVE_ITEM]);
    //     return uploadDriveItem(self.httpClient, path, binaryStream, mimeType); 
    // }
    
    // # Update the contents of an existing file in the Drive. This method only supports files up to 4MB in size.
    // # Here, the type of the file should be the same type as the file we replace with.
    // # 
    // # + itemId - The ID of the DriveItem
    // # + binaryStream - An stream of `byte[]` that represents a binary stream of the file to be uploaded
    // # + mimeType - The media type of the uploading file
    // # + return - A record of type `DriveItemData` if success. Else `Error`.
    // @display {label: "Replace file (ID based)"}
    // remote isolated function replaceFileUsingId(@display {label: "Item ID"} string itemId,
    //                                             @display {label: "Stream of bytes to upload"}  
    //                                             stream<byte[],io:Error?> binaryStream, 
    //                                             @display {label: "Mime Type"} string mimeType) returns 
    //                                             @display {label: "DriveItem Metadata"} DriveItemData|Error {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         CONTENT_OF_DRIVE_ITEM]);
    //     return uploadDriveItem(self.httpClient, path, binaryStream, mimeType); 
    // }

    // # Update the contents of an existing file in the Drive. This method only supports files up to 4MB in size.
    // # Here, the type of the file should be the same type as the file we replace with.
    // # 
    // # + itemPath - The file system path of the File. The hierarchy of the path allowed in this function is relative
    // #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    // # + binaryStream - An stream of `byte[]` that represents a binary stream of the file to be uploaded
    // # + mimeType - The media type of the uploading file
    // # + return - A record of type `DriveItemData` if success. Else `Error`.
    // @display {label: "Replace file (Path based)"}
    // remote isolated function replaceFileUsingPath(@display {label: "Item Path Relative to Drive Root"} string itemPath, 
    //                                               @display {label: "Stream of bytes to upload"}  
    //                                               stream<byte[],io:Error?> binaryStream, 
    //                                               @display {label: "Mime Type"} string mimeType) returns 
    //                                               @display {label: "DriveItem Metadata"} DriveItemData|Error {
    //     string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
    //         [CONTENT_OF_DRIVE_ITEM]);
    //     return uploadDriveItem(self.httpClient, path, binaryStream, mimeType); 
    // }
    //******************************************************************************************************************

    //************************ Functions for uploading and replacing the files using byte[] ****************************
    # Uploads a new file to the Drive. <br/> This method only supports files up to 4MB in size.
    # 
    # + parentFolderId - The folder ID of the parent folder where, the new file will be uploaded
    # + fileName - The name of the new file
    # + byteArray - An array of `byte` that represents a binary form of the file to be uploaded
    # + mimeType - The mime type of the uploading file
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Upload file (ID based)"}
    remote isolated function uploadFileToFolderById(@display {label: "Parent Folder ID"} string parentFolderId, 
                                                    @display {label: "File Name"} string fileName, 
                                                    @display {label: "Array of Bytes"} byte[] byteArray, 
                                                    @display {label: "Mime Type"} string mimeType) returns 
                                                    DriveItemData|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, parentFolderId], 
            string `/${fileName}`, [CONTENT_OF_DRIVE_ITEM]);
        return uploadDriveItemByteArray(self.httpClient, path, byteArray, mimeType); 
    }

    # Uploads a new file to the Drive. <br/> This method only supports files up to 4MB in size.
    # 
    # + parentFolderPath - The folder path of the parent folder relative to the `root` of the respective Drive where, 
    #                      the new folder will be created
    #                    - **NOTE:** When you want to create a folder on root itself, you must give the relative path of the new folder only.    
    # + fileName - The name of the new file
    # + byteArray - An array of `byte` that represents a binary form of the file to be uploaded
    # + mimeType - The mime type of the uploading file
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Upload file (Path based)"}
    remote isolated function uploadFileToFolderByPath(@display {label: "Parent Folder Path"} string parentFolderPath, 
                                                      @display {label: "File Name"} string fileName, 
                                                      @display {label: "Array of Bytes"} byte[] byteArray, 
                                                      @display {label: "Mime Type"} string mimeType) returns 
                                                      DriveItemData|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], 
            string `${parentFolderPath}/${fileName}`, [CONTENT_OF_DRIVE_ITEM]);
        return uploadDriveItemByteArray(self.httpClient, path, byteArray, mimeType); 
    }

    # Updates the contents of an existing file in the Drive. <br/> This method only supports files up to 4MB in size.
    # Here, the type of the file should be the same type as the file we replace with.
    # 
    # + itemId - The ID of the DriveItem
    # + byteArray - An array of `byte` that represents a binary form of the file to be uploaded
    # + mimeType - The mime type of the uploading file
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Replace file (ID based)"}
    remote isolated function replaceFileUsingId(@display {label: "Item ID"} string itemId, 
                                                @display {label: "Array of Bytes"} byte[] byteArray, 
                                                @display {label: "Mime Type"} string mimeType) returns 
                                                DriveItemData|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
            CONTENT_OF_DRIVE_ITEM]);
        return uploadDriveItemByteArray(self.httpClient, path, byteArray, mimeType); 
    }

    # Updates the contents of an existing file in the Drive. <br/> This method only supports files up to 4MB in size.
    # Here, the type of the file should be the same type as the file we replace with.
    # 
    # + itemPath - The file system path of the File
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    #            - **example:** Use the itempath as `/Documents/MyFile.xlsx` if MyFile.xlsx is located inside a folder called Docuements.
    # + byteArray - An array of `byte` that represents a binary form of the file to be uploaded
    # + mimeType - The mime type of the uploading file
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Replace file (Path based)"}
    remote isolated function replaceFileUsingPath(@display {label: "Item Path Relative to Drive Root"} string itemPath,                                                    
                                                  @display {label: "Array of Bytes"} byte[] byteArray, 
                                                  @display {label: "Mime Type"} string mimeType) returns 
                                                  DriveItemData|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
            [CONTENT_OF_DRIVE_ITEM]);
        return uploadDriveItemByteArray(self.httpClient, path, byteArray, mimeType); 
    }
    //******************************************************************************************************************

    # Uploads files up to the maximum file size. <br/> **NOTE:** Maximum bytes in any given request is less than 60 MiB.
    # 
    # + itemPath - The file system path of the file (with extention)
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + itemInfo - Additional data about the file being uploaded
    # + binaryStream - Stream of content of file which we need to be uploaded
    #                - The size of each byte range in the stream **MUST** be a multiple of 320 KiB (327,680 bytes). 
    #                - The recommended fragment size is between 5-10 MiB (5,242,880 bytes - 10,485,760 bytes)
    #                - **Note:** For more information about upload large files, [visit](https://docs.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_createuploadsession?view=odsp-graph-online#best-practices).
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Upload a large file"}
    remote function resumableUploadDriveItem(@display {label: "Item Path Relative to Drive Root"} string itemPath, 
                                             @display {label: "Information About File"} UploadMetadata itemInfo, 
                                             @display {label: "Stream of Bytes"} 
                                             stream<io:Block,io:Error?> binaryStream) returns DriveItemData|Error { 
        string path = check createPathBasedUrl([DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [CREATE_UPLOAD_SESSION_ACTION]);
        json payload = {
            item: check mapItemInfoToJson(itemInfo)
        };        
        http:Response response = check self.httpClient->post(path, payload);
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            UploadSession session = check handledResponse.cloneWithType(UploadSession);
            int remainingBytes = itemInfo.fileSize;
            int startByte = ZERO;
            int endByte = ZERO;
                map<json> finalData = {};
                error? e = binaryStream.forEach(function(io:Block byteBlock) {
                    if (byteBlock.length() < MAXIMUM_FRAGMENT_SIZE) {
                        endByte = startByte + (byteBlock.length()-1);
                        if (remainingBytes < byteBlock.length()) {
                            byte[] lastByteArray = byteBlock.slice(ZERO, remainingBytes);
                            finalData = <@untainted>checkpanic uploadBytes(itemInfo.fileSize, lastByteArray, startByte, 
                                endByte, <@untainted>session?.uploadUrl);
                            log:printInfo("Upload successful");
                        } else {
                            finalData = <@untainted>checkpanic uploadBytes(itemInfo.fileSize, byteBlock, startByte, endByte, 
                                <@untainted>session?.uploadUrl);
                            startByte += byteBlock.length();
                            remainingBytes -= byteBlock.length();
                            log:printInfo("Remaining bytes to upload: " + remainingBytes.toString() + " bytes");
                        }
                    } else {
                        panic error InputValidationError(MAX_FRAGMENT_SIZE_EXCEEDED);
                    }
                });
                return check convertToDriveItem(finalData);
            
        } else {
            return error PayloadValidationError(INVALID_RESPONSE);
        }
    }

    # Searches the hierarchy of items for items matching a query.
    # 
    # + searchText - The query text used to search for items
    #              - Values may be matched across several fields including 
    #                filename, metadata, and file content.
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A stream  `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Search drive items"}
    remote isolated function searchDriveItems(@display {label: "Search text"} string searchText, 
                                              @display {label: "Optional Query Parameters"} string? queryParams = ()) 
                                              returns @display {label: "DriveItem Stream"} 
                                              stream<DriveItemData, Error>|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT, 
            string `search(q='${searchText}')`]);
        DriveItemStream objectInstance = check new (self.config, self.httpClient, path, queryParams);
        stream<DriveItemData, error> finalStream = new (objectInstance);
        return finalStream;
    }

    // ****************************************** Operations on Permissions ********************************************
    // The Permission resource provides information about a sharing permission granted for a DriveItem resource.

    # Creates a new sharing link if the specified link type doesn't already exist for the 
    # calling application. <br/> If a sharing link of the specified type already exists for the app, the existing sharing 
    # link will be returned.
    # 
    # + itemId - The ID of the DriveItem
    # + options - A record `onedrive:PermissionOptions` that represents the properties of the sharing link your 
    #             application is requesting
    # + return - A record `onedrive:Permission` if sucess. Else `onedrive:Error`.
    @display {label: "Get sharable links (ID based)"}
    remote isolated function getSharableLinkFromId(@display {label: "Item ID"} string itemId, 
                                                   @display {label: "Permission Options"} PermissionOptions options) 
                                                   returns @display {label: "Permission Information"} Permission|Error {
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
            CREATE_LINK_ACTION]);
        return check getSharableLink(self.httpClient, path, options);
    }

    # Creates a new sharing link if the specified link type doesn't already exist for the 
    # calling application. <br/> If a sharing link of the specified type already exists for the app, the existing sharing 
    # link will be returned.
    # 
    # + itemPath - The file system path of the File
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + options - A record `onedrive:PermissionOptions` that represents the properties of the sharing link your 
    #             application is requesting
    # + return - A record  `onedrive:Permission` if sucess. Else `onedrive:Error`.
    @display {label: "Get sharable links (Path based)"}
    remote isolated function getSharableLinkFromPath(@display {label: "Item Path Relative to Drive Root"} 
                                                     string itemPath, 
                                                     @display {label: "Permission Options"} PermissionOptions options)
                                                     returns Permission|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
            [CREATE_LINK_ACTION]);
        return check getSharableLink(self.httpClient, path, options);
    }

    # Accesses a shared DriveItem by using sharing URL.
    # 
    # + sharingUrl - The URL that represents a sharing link reated for a DriveItem
    # + return - A record `onedrive:DriveItemData` if sucess. Else `onedrive:Error`.
    @display {label: "Get shared item metadata"}
    remote isolated function getSharedDriveItem(@display {label: "Shared URL"} string sharingUrl) returns 
                                                DriveItemData|Error {
        string encodedSharingUrl = encodeSharingUrl(sharingUrl);
        string path = check createUrl([SHARED_RESOURCES, encodedSharingUrl, DRIVEITEM_RESOURCE]);
        http:Response response = check self.httpClient->get(path);
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            return check convertToDriveItem(handledResponse);
        } else {
            return error PayloadValidationError(INVALID_RESPONSE);
        }
    }

    # Sends a sharing invitation for a DriveItem. <br/> A sharing invitation provides permissions to the recipients and
    # optionally sends them an email with a sharing link.
    # 
    # + itemId - The ID of the DriveItem
    # + invitation - A record `onedrive:ItemShareInvitation` that contain metadata for sharing
    # + return - A record `onedrive:Permission` if sucess. Else `onedrive:Error`.
    @display {label: "Send Sharing Invitation (ID based)"}
    remote isolated function sendSharingInvitationById(@display {label: "Item ID"} string itemId, 
                                                       @display {label: "Sharing Invitation"} 
                                                       ItemShareInvitation invitation) returns Permission|Error { 
        string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, INVITE_ACTION]);
        return check sendSharableLink(self.httpClient, path, invitation);
    }

    # Sends a sharing invitation for a DriveItem. <br/> A sharing invitation provides permissions to the recipients and
    # optionally sends them an email with a sharing link.
    # 
    # + itemPath - The file system path of the File 
    #            - The hierarchy of the path allowed in this function is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + invitation - A record `onedrive:ItemShareInvitation` that contain metadata for sharing
    # + return - A record `onedrive:Permission` if sucess. Else `onedrive:Error`.
    @display {label: "Send Sharing Invitation (Path based)"}
    remote isolated function sendSharingInvitationByPath(@display {label: "Item Path Relative to Drive Root"} 
                                                         string itemPath, @display {label: "Sharing Invitation"} 
                                                         ItemShareInvitation invitation) returns Permission|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [INVITE_ACTION]);
        return check sendSharableLink(self.httpClient, path, invitation);
    }

    // *************************Supported only in Azure work and School accounts (NOT TESTED) **************************
    // remote isolated function checkInDriveItem(@display {label: "Item ID"} string itemId, CheckInOptions options) 
    //                                           returns Error? {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId,
    //         CHECK_IN_ACTION]);
    //     json payload = check options.cloneWithType(json);
    //     http:Response response = check self.httpClient->post(path, payload);
    //     _ = check handleResponse(response);
    // }

    // remote isolated function checkOutDriveItem(@display {label: "Item ID"} string itemId) returns Error? {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         CHECK_OUT_ACTION]);
    //     http:Request request = new;
    //     http:Response response = check self.httpClient->post(path, request);
    //     _ = check handleResponse(response);
    // }

    // remote isolated function followDriveItem(@display {label: "Item ID"} string itemId) returns 
    //                                          DriveItemData|Error {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         FOLLOW_ACTION]);
    //     http:Request request = new;
    //     http:Response response = check self.httpClient->post(path, request);
    //     map<json>|string? handledResponse = check handleResponse(response);
    //     if (handledResponse is map<json>) {
    //         return check convertToDriveItem(handledResponse);
    //     } else {
    //         return error PayloadValidationError(INVALID_RESPONSE);
    //     } 
    // }

    // remote isolated function unfollowDriveItem(@display {label: "Item ID"} string itemId) returns Error? {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         UNFOLLOW_ACTION]);
    //     http:Request request = new;
    //     http:Response response = check self.httpClient->post(path, request);
    //     _ = check handleResponse(response);
    // }

    // remote isolated function getItemsFollowed() returns DriveItemData[]|Error {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, FOLLOWING_BY_LOGGED_IN_USER]);
    //     return check getDriveItemArray(self.httpClient, path);
    // }
    
    // remote isolated function getDriveItemPreview(@display {label: "Item ID"} string itemId, 
    //                                              PreviewOptions? options = ()) returns 
    //                                              EmbeddableData|Error {
    //     string path = check createUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         PREVIEW_ACTION]);
    //     http:Request request = new;
    //     if (options != ()) {
    //         json payload = check options.cloneWithType(json);
    //         request.setJsonPayload(payload);
    //     }
    //     http:Response response = check self.httpClient->post(path, request);
    //     map<json>|string? handledResponse = check handleResponse(response);
    //     if (handledResponse is map<json>) {
    //         return check handledResponse.cloneWithType(EmbeddableData);
    //     } else {
    //         return error PayloadValidationError(INVALID_RESPONSE);
    //     }
    // }

    // remote isolated function getItemStatistics(string driveId, @display {label: "Item ID"} string itemId) returns 
    //                                            ItemAnalytics|Error {
    //     string path = check createUrl([ALL_DRIVES, driveId, ALL_DRIVE_ITEMS, itemId, ANALYTICS_RESOURCES]);
    //     http:Response response = check self.httpClient->get(path);
    //     map<json>|string? handledResponse = check handleResponse(response);
    //     if (handledResponse is map<json>) {
    //         return check handledResponse.cloneWithType(ItemAnalytics);
    //     } else {
    //         return error PayloadValidationError(INVALID_RESPONSE);
    //     }
    // }
}

# Resource that provides information about how to upload large files to OneDrive
#
# + uploadUrl - The URL endpoint that accepts PUT requests for byte ranges of the file 
# + expirationDateTime - The date and time in UTC that the upload session will expire. The complete file must be 
#                        uploaded before this expiration time is reached.
# + nextExpectedRanges - A collection of byte ranges that the server is missing for the file. These ranges are zero 
#                        indexed and of the format "start-end" (e.g. "0-26" to indicate the first 27 bytes of the file)
type UploadSession record {
    string uploadUrl;
    string expirationDateTime?;
    string[] nextExpectedRanges?;
};
