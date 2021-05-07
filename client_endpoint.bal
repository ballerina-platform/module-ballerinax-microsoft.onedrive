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

# OneDrive Client Object for executing drive operations.
# 
# + httpClient - the HTTP Client
public client class Client {
    http:Client httpClient;

    public isolated function init(Configuration config) returns error? {
        http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig = config.clientConfig;
        http:ClientSecureSocket? socketConfig = config?.secureSocketConfig;
        self.httpClient = check new (BASE_URL, {
            auth: clientConfig,
            secureSocket: socketConfig,
            followRedirects: {enabled: true, maxCount: 5}
        });
    }

    // ************************************* Operations on a Drive resource ********************************************
    // The Drive resource is the top-level object representing a user's OneDrive.

    # Lists a set of items that have been recently used by the `signed in user`. This will include items that are in the
    # user's drive as well as the items they have access to from other drives.
    # 
    # + return - An array of type `DriveItem` if sucess. Else `Error`
    remote isolated function getRecentItems() returns @tainted DriveItem[]|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, RECENT_ITEMS]);
        return check getDriveItemArray(self.httpClient, path);
    }

    # Retrieve a collection of `DriveItem` resources that have been shared with the `signed in user` of the OneDrive.
    # 
    # + queryParams - An array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 (By default, sharedWithMe return items shared within your own tenant. To include items shared from
    #                  external tenants, append `allowexternal=true` query parameter)
    # + return - An array of type `DriveItem` if sucess. Else `Error`
    remote isolated function getItemsSharedWithMe(string[] queryParams = []) returns @tainted DriveItem[]|error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, SHARED_WITH_LOGGED_IN_USER], 
            queryParams);
        return check getDriveItemArray(self.httpClient, path);
    }

    // ************************************ Operations on a DriveItem resource *****************************************
    // The DriveItem resource represents a file, folder, or other item stored in OneDrive.
  
    # Create a new folder in a Drive with a specified parent item, referred with the parent folder's ID.
    # 
    # + parentFolderId - The folder ID of the parent folder where, the new folder will be created.
    # + folderMetadata - A record of type `FolderMetadata` which contains the necessary data to create a folder
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function createFolderById(string parentFolderId, FolderMetadata folderMetadata) returns 
                                              @tainted DriveItem|Error { 
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, parentFolderId, CHILDREN_RESOURCES]);
        return check createFolder(self.httpClient, path, folderMetadata);
    }

    # Create a new folder in a Drive with a specified parent item referred with the folder path.
    # 
    # + parentFolderPath - The folder path of the parent folder relative to the `root` of the respective Drive where, 
    #                      the new folder will be created.
    #                      **NOTE:** When you want to create a folder on root itself, you must give the relative path of 
    #                      the new folder only.
    # + folderMetadata - A record of type `FolderMetadata` which contains the necessary data to create a folder
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function createFolderByPath(string parentFolderPath, FolderMetadata folderMetadata) returns 
                                                @tainted DriveItem|Error {
        string path = EMPTY_STRING;
        if (parentFolderPath == EMPTY_STRING || parentFolderPath == FORWARD_SLASH) {
            path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT, CHILDREN_RESOURCES]);
        } else {
            path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], parentFolderPath, 
                [CHILDREN_RESOURCES]);
        }
        return check createFolder(self.httpClient, <@untainted>path, folderMetadata);
    }

    # Retrieve the metadata for a DriveItem in a Drive by item ID.
    # 
    # + itemId - The ID of the DriveItem
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function getItemMetadataById(string itemId, string[] queryParams = []) returns 
                                                 @tainted DriveItem|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId], queryParams);
        return check getDriveItem(self.httpClient, <@untainted>path);
    }

    # Retrieve the metadata for a DriveItem in a Drive by file system path.
    # 
    # + itemPath - The file syatem path of the DriveItem. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function getItemMetadataByPath(string itemPath, string[] queryParams = []) returns 
                                                   @tainted DriveItem|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [], queryParams);
        return check getDriveItem(self.httpClient, <@untainted>path);
    }

    # Update the metadata for a DriveItem in a Drive referring by item ID.
    # 
    # + itemId - The ID of the DriveItem
    # + replacementData - A record of type `DriveItem` which contains the values for properties that should be updated
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function updateDriveItemById(string itemId, DriveItem replacementData) returns 
                                                 @tainted DriveItem|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId]);
        return updateDriveItem(self.httpClient, <@untainted>path, replacementData); 
    }

    # Update the metadata for a DriveItem in a Drive by file system path.
    # 
    # + itemPath - The file syatem path of the DriveItem. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + replacementData - A record of type `DriveItem` which contains the values for properties that should be updated
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function updateDriveItemByPath(string itemPath, DriveItem replacementData) returns 
                                                   @tainted DriveItem|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath);
        return updateDriveItem(self.httpClient, <@untainted>path, replacementData); 
    }

    # Delete a DriveItem in a Drive by using it's ID.
    # 
    # + itemId - The ID of the DriveItem
    # + return - Returns `nil` is success. Else `Error`
    remote isolated function deleteDriveItemById(string itemId) returns @tainted Error? {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId]);
        http:Response response = check self.httpClient->delete(<@untainted>path);
        _ = check handleResponse(response);
    }

    # Delete a DriveItem in a Drive by using it's file syatem path.
    # 
    # + itemPath - The file syatem path of the DriveItem. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + return - Returns `nil` is success. Else `Error`
    remote isolated function deleteDriveItemByPath(string itemPath) returns @tainted Error? {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath);
        http:Response response = check self.httpClient->delete(<@untainted>path);
        _ = check handleResponse(response);
    }

    # Restore a driveItem that has been deleted and is currently in the recycle bin. **NOTE:** This functionality is 
    # currently only available for OneDrive Personal.
    # 
    # + itemId - The ID of the DriveItem
    # + parentReference - Optional. A record of type `ItemReference` that represents reference to the parent item the 
    #                     deleted item will be restored to.
    # + name - Optional. The new name for the restored item. If this isn't provided, the same name will be used as 
    #          the original.
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function restoreDriveItem(string itemId, ItemReference? parentReference = (), string? name = ())
                                              returns @tainted DriveItem|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
            RESTORE_ACTION]);
        json restoreItemOptions = {};
        if (name is () && parentReference != ()) {
            restoreItemOptions = {
                                    parentReference : check parentReference.cloneWithType(json)
                                 };
        } else if (name != () && parentReference != ()) {
            restoreItemOptions = {
                                    parentReference : check parentReference.cloneWithType(json),
                                    name: name
                                 };
        } else if (name != () && parentReference is ()) {
            restoreItemOptions = {
                                    name: name
                                 };
        }
        http:Response response = check self.httpClient->post(<@untainted>path, restoreItemOptions);
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            return check convertToDriveItem(handledResponse);
        } else {
            return error PayloadValidationError("Invalid response");
        }
    }

    # Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same 
    # location with a new name.
    # 
    # + itemId - The ID of the DriveItem
    # + name - Optional. The new name for the copy. If this isn't provided, the same name will be used as the original.
    # + parentReference - Optional. A record of type `ItemReference` that represents reference to the parent item the 
    #                     copy will be created in.
    # + return - A `string` which represents the ID of the newly created copy if sucess. Else `Error`
    remote isolated function copyDriveItemWithId(string itemId, string? name = (), ItemReference? parentReference = ()) 
                                                 returns @tainted string|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, COPY_ACTION]);
        return check copyDriveItem(self.httpClient, <@untainted>path, parentReference, name);
    }

    # Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same 
    # location with a new name.
    # 
    # + itemPath - The file syatem path of the DriveItem. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + name - Optional. The new name for the copy. If this isn't provided, the same name will be used as the original.
    # + parentReference - Optional. A record of type `ItemReference` that represents reference to the parent item the 
    #                     copy will be created in.
    # + return - A `string` which represents the ID of the newly created copy if sucess. Else `Error`
    remote isolated function copyDriveItemInPath(string itemPath, string? name = (), ItemReference? parentReference = ()) 
                                                 returns @tainted string|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [COPY_ACTION]);
        return check copyDriveItem(self.httpClient, <@untainted>path, parentReference, name);
    }

    # Download the contents of the primary stream (file) of a DriveItem using item ID. **NOTE:** Only driveItems with 
    # the file property can be downloaded.
    # 
    # + itemId - The ID of the DriveItem
    # + formatToConvert - Optional. Specify the format the item's content should be downloaded as.
    # + return - A record of type `File`
    remote isolated function downloadFileById(string itemId, FileFormat? formatToConvert = ()) returns 
                                              @tainted File|Error {
        string path = EMPTY_STRING;
        if (formatToConvert is ()) {
            path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
                CONTENT_OF_DRIVE_ITEM]);
        } else {
            path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
                CONTENT_OF_DRIVE_ITEM], [string `format=${formatToConvert.toString()}`]);
        }
        return check downloadDriveItem(self.httpClient, <@untainted>path);
    }

    # Download the contents of the primary stream (file) of a DriveItem using item path. **NOTE:** Only driveItems 
    # with the file property can be downloaded.
    # 
    # + itemPath - The file syatem path of the File. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + formatToConvert - Optional. Specify the format the item's content should be downloaded as.
    # + return - A record of type `File` if successful. Else `Error`.
    remote isolated function downloadFileByPath(string itemPath, FileFormat? formatToConvert = ()) returns 
                                                @tainted File|Error {
        string path = EMPTY_STRING;
        if (formatToConvert is ()) {
            path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
                [CONTENT_OF_DRIVE_ITEM]);
        } else {
            path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
                [CONTENT_OF_DRIVE_ITEM], [string `format=${formatToConvert.toString()}`]);
        }
        return check downloadDriveItem(self.httpClient, <@untainted>path);
    }

    # Download the contents of the primary stream (file) of a DriveItem using download URL. **NOTE:** Only driveItems 
    # with the file property can be downloaded.
    # 
    # + downloadUrl - Download URL for a specific DriveItem
    # + partialContentOption - Optional. The value fpr the `Range` header to download a partial range of bytes from the 
    #                          file.
    # + return - A record of type `File` if successful. Else `Error`.
    remote isolated function downloadFileByDownloadUrl(string downloadUrl, ByteRange? partialContentOption = ()) returns 
                                                       @tainted File|Error {
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

    # Upload a new file to the Drive. This method only supports files up to 4MB in size.
    # 
    # + parentFolderId - The folder ID of the parent folder where, the new file will be uploaded
    # + fileName - The name of the new file
    # + binaryRepresentation - An array of `bytes` that represents a binary stream of the file to be uploaded
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function uploadDriveItemToFolderById(string parentFolderId, string fileName, 
                                                         stream<byte[],io:Error?> binaryRepresentation) returns 
                                                         @tainted DriveItem|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, parentFolderId], 
            string `/${fileName}`, [CONTENT_OF_DRIVE_ITEM]);
        return uploadDriveItem(self.httpClient, <@untainted>path, binaryRepresentation); 
    }

    # Upload a new file to the Drive. This method only supports files up to 4MB in size.
    # 
    # + parentFolderPath - The folder path of the parent folder relative to the `root` of the respective Drive where, 
    #                      the new folder will be created.
    #                      **NOTE:** When you want to create a folder on root itself, you must give the relative path of 
    #                      the new folder only.
    # + fileName - The name of the new file
    # + binaryRepresentation - An array of `bytes` that represents a binary stream of the file to be uploaded
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function uploadDriveItemToFolderByPath(string parentFolderPath, string fileName, 
                                                           stream<byte[],io:Error?> binaryRepresentation) returns 
                                                           @tainted DriveItem|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], 
            string `${parentFolderPath}/${fileName}`, [CONTENT_OF_DRIVE_ITEM]);
        return uploadDriveItem(self.httpClient, <@untainted>path, binaryRepresentation); 
    }

    # Update the contents of an existing file in the Drive. This method only supports files up to 4MB in size.
    # Here, the type of the file should be the same type as the file we replace with.
    # 
    # + itemId - The ID of the DriveItem
    # + binaryRepresentation - An array of `bytes` that represents a binary stream of the file to be uploaded
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function replaceFileUsingId(string itemId, byte[] binaryRepresentation) returns 
                                                @tainted DriveItem|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
            CONTENT_OF_DRIVE_ITEM]);
        return check replaceFile(self.httpClient, <@untainted>path, binaryRepresentation);
    }

    # Update the contents of an existing file in the Drive. This method only supports files up to 4MB in size.
    # Here, the type of the file should be the same type as the file we replace with.
    # 
    # + itemPath - The file syatem path of the File. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + binaryRepresentation - An array of `bytes` that represents a binary stream of the file to be uploaded
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function replaceFileUsingPath(string itemPath, byte[] binaryRepresentation) returns 
                                                  @tainted DriveItem|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
            [CONTENT_OF_DRIVE_ITEM]);
        return check replaceFile(self.httpClient, <@untainted>path, binaryRepresentation);
    }

    # Upload files up to the maximum file size. **NOTE:** Maximum bytes in any given request is less than 60 MiB.
    # 
    # + itemPath - The file syatem path of the file (with extention). The hierarchy of the path allowed in this function 
    #              is relative to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + itemInfo - Additional data about the file being uploaded
    # + fileStream - Stream of content of file which we need to be uploaded. The size of each byte range in the stream 
    #                **MUST** be a multiple of 320 KiB (327,680 bytes). The recommended fragment size is between 
    #                5-10 MiB (5,242,880 bytes - 10,485,760 bytes)
    #                **Note:** For more information about upload large files, refer here: 
    #                https://docs.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_createuploadsession?view=odsp-graph-online#best-practices
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote function resumableUploadDriveItem(string itemPath, ItemInfo itemInfo, stream<io:Block,io:Error?> fileStream) 
                                             returns @tainted DriveItem|Error { 
        string path = check createPathBasedUrl([DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [CREATE_UPLOAD_SESSION_ACTION]);
        json payload = {
            item: check mapItemInfoToJson(itemInfo)
        };        
        http:Response response = check self.httpClient->post(<@untainted>path, payload);
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            UploadSession session = check handledResponse.cloneWithType(UploadSession);

            int remainingBytes = itemInfo.fileSize;
            int startByte = ZERO;
            int endByte = ZERO;
            map<json> finalData = {};
            error? e = fileStream.forEach(function(io:Block byteBlock) {
                if (byteBlock.length() < MAXIMUM_FRAGMENT_SIZE) {
                    endByte = startByte + (byteBlock.length()-1);
                    if (remainingBytes < byteBlock.length()) {
                        byte[] lastByteArray = byteBlock.slice(ZERO, remainingBytes);
                        finalData = <@untainted>checkpanic uploadBytes(itemInfo.fileSize, lastByteArray, startByte, endByte, 
                            <@untainted>session?.uploadUrl);
                        log:printInfo("Upload successful");
                    } else {
                        finalData = <@untainted>checkpanic uploadBytes(itemInfo.fileSize, byteBlock, startByte, endByte, 
                            <@untainted>session?.uploadUrl);
                        startByte += byteBlock.length();
                        remainingBytes -= byteBlock.length();
                        log:printInfo("Remaining bytes to upload: " + remainingBytes.toString() + "bytes");
                    }
                } else {
                    panic error InputValidationError("The content exceeds the maximum fragment size");
                }
            });
            return check convertToDriveItem(finalData);
        } else {
            return error PayloadValidationError("Invalid response");
        }
    }

    # Search the hierarchy of items for items matching a query.
    # 
    # + searchText - The query text used to search for items. Values may be matched across several fields including 
    #                filename, metadata, and file content.
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** Refer more information about query parameters here: https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A stream of type `DriveItem` if sucess. Else `Error`
    remote isolated function searchDriveItems(string searchText, string[] queryParams = []) returns 
                                              @tainted stream<DriveItem, Error>|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT, 
            string `search(q='${searchText}')`]);
        DriveItemStream objectInstance = check new (self.httpClient, <@untainted>path);
        stream<DriveItem, error> finalStream = new (objectInstance);
        return finalStream;
    }

    // ****************************************** Operations on Permissions ********************************************
    // The Permission resource provides information about a sharing permission granted for a DriveItem resource.

    # Create a new sharing link if the specified link type doesn't already exist for the 
    # calling application. If a sharing link of the specified type already exists for the app, the existing sharing 
    # link will be returned.
    # 
    # + itemId - The ID of the DriveItem
    # + options - A record of type `PermissionOptions` that represents the properties of the sharing link your 
    #             application is requesting.
    # + return - A record of type `Permission` if sucess. Else `Error`
    remote isolated function getSharableLinkFromId(string itemId, PermissionOptions options) returns 
                                                   @tainted Permission|Error {
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
            CREATE_LINK_ACTION]);
        return check getSharableLink(self.httpClient, <@untainted>path, options);
    }

    # Create a new sharing link if the specified link type doesn't already exist for the 
    # calling application. If a sharing link of the specified type already exists for the app, the existing sharing 
    # link will be returned.
    # 
    # + itemPath - The file syatem path of the File. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + options - A record of type `PermissionOptions` that represents the properties of the sharing link your 
    #             application is requesting.
    # + return - A record of type `Permission` if sucess. Else `Error`
    remote isolated function getSharableLinkFromPath(string itemPath, PermissionOptions options) returns 
                                                     @tainted Permission|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, 
            [CREATE_LINK_ACTION]);
        return check getSharableLink(self.httpClient, <@untainted>path, options);
    }

    # Access a shared DriveItem by using sharing URL.
    # 
    # + sharingUrl - The URL that represents a sharing link reated for a DriveItem
    # + return - A record of type `DriveItem` if sucess. Else `Error`
    remote isolated function getSharedDriveItem(string sharingUrl) returns @tainted DriveItem|Error {
        string encodedSharingUrl = encodeSharingUrl(sharingUrl);
        string path = check createRequestPath([SHARED_RESOURCES, encodedSharingUrl, DRIVEITEM_RESOURCE]);
        http:Response response = check self.httpClient->get(path);
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            return check convertToDriveItem(handledResponse);
        } else {
            return error PayloadValidationError("Invalid response");
        }
    }

    # Sends a sharing invitation for a DriveItem. A sharing invitation provides permissions to the recipients and
    # optionally sends them an email with a sharing link.
    # 
    # + itemId - The ID of the DriveItem
    # + invitation - A record of type `ItemShareInvitation` that contain metadata for sharing
    # + return - A record of type `Permission` if sucess. Else `Error`
    remote isolated function sendSharingInvitationById(string itemId, ItemShareInvitation invitation) returns 
                                                       @tainted Permission|Error { 
        string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, INVITE_ACTION]);
        return check sendSharableLink(self.httpClient, <@untainted>path, invitation);
    }

    # Sends a sharing invitation for a DriveItem. A sharing invitation provides permissions to the recipients and
    # optionally sends them an email with a sharing link.
    # 
    # + itemPath - The file syatem path of the File. The hierarchy of the path allowed in this function is relative
    #              to the `root` of the respective Drive. So, the relative path from `root` must be provided.
    # + invitation - A record of type `ItemShareInvitation` that contain metadata for sharing
    # + return - A record of type `Permission` if sucess. Else `Error`
    remote isolated function sendSharingInvitationByPath(string itemPath, ItemShareInvitation invitation) returns 
                                                         @tainted Permission|Error {
        string path = check createPathBasedUrl([LOGGED_IN_USER, DRIVE_RESOURCE, DRIVE_ROOT], itemPath, [INVITE_ACTION]);
        return check sendSharableLink(self.httpClient, <@untainted>path, invitation);
    }

    // *************************Supported only in Azure work and School accounts (NOT TESTED) **************************
    // remote isolated function checkInDriveItem(string itemId, CheckInOptions options) returns @tainted Error? {
    //     string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId,
    //         CHECK_IN_ACTION]);
    //     json payload = check options.cloneWithType(json);
    //     http:Response response = check self.httpClient->post(<@untainted>path, payload);
    //     _ = check handleResponse(response);
    // }

    // remote isolated function checkOutDriveItem(string itemId) returns @tainted Error? {
    //     string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         CHECK_OUT_ACTION]);
    //     http:Request request = new;
    //     http:Response response = check self.httpClient->post(<@untainted>path, request);
    //     _ = check handleResponse(response);
    // }

    // remote isolated function followDriveItem(string itemId) returns @tainted DriveItem|Error {
    //     string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         FOLLOW_ACTION]);
    //     http:Request request = new;
    //     http:Response response = check self.httpClient->post(<@untainted>path, request);
    //     map<json>|string? handledResponse = check handleResponse(response);
    //     if (handledResponse is map<json>) {
    //         return check convertToDriveItem(handledResponse);
    //     } else {
    //         return error PayloadValidationError("Invalid response");
    //     } 
    // }

    // remote isolated function unfollowDriveItem(string itemId) returns @tainted Error? {
    //     string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         UNFOLLOW_ACTION]);
    //     http:Request request = new;
    //     http:Response response = check self.httpClient->post(<@untainted>path, request);
    //     _ = check handleResponse(response);
    // }

    // remote isolated function getItemsFollowed() returns @tainted DriveItem[]|Error {
    //     string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, FOLLOWING_BY_LOGGED_IN_USER]);
    //     return check getDriveItemArray(self.httpClient, <@untainted>path);
    // }
    
    // remote isolated function getDriveItemPreview(string itemId, PreviewOptions? options = ()) returns 
    //                                              @tainted EmbeddableData|Error {
    //     string path = check createRequestPath([LOGGED_IN_USER, DRIVE_RESOURCE, ALL_DRIVE_ITEMS, itemId, 
    //         PREVIEW_ACTION]);
    //     http:Request request = new;
    //     if (options != ()) {
    //         json payload = check options.cloneWithType(json);
    //         request.setJsonPayload(payload);
    //     }
    //     http:Response response = check self.httpClient->post(<@untainted>path, request);
    //     map<json>|string? handledResponse = check handleResponse(response);
    //     if (handledResponse is map<json>) {
    //         return check handledResponse.cloneWithType(EmbeddableData);
    //     } else {
    //         return error PayloadValidationError("Invalid response");
    //     }
    // }

    // remote isolated function getItemStatistics(string driveId, string itemId) returns @tainted ItemAnalytics|Error {
    //     string path = check createRequestPath([ALL_DRIVES, driveId, ALL_DRIVE_ITEMS, itemId, ANALYTICS_RESOOURCES]);
    //     http:Response response = check self.httpClient->get(<@untainted>path);
    //     map<json>|string? handledResponse = check handleResponse(response);
    //     if (handledResponse is map<json>) {
    //         return check handledResponse.cloneWithType(ItemAnalytics);
    //     } else {
    //         return error PayloadValidationError("Invalid response");
    //     }
    // }
}
