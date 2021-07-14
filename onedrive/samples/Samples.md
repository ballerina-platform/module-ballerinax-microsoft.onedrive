# Samples
## Get DriveItem metadata
Retrieve the metadata for a DriveItem in a Drive by item ID or file system path (relative path). 

- [ID based addressing sample](get_item_metadata_by_id.bal)

- [Path based addressing sample](get_item_metadata_by_path.bal)

**Note:** <br/>
This operation supports several OData query parameters as well as normal query parameters.
* **$expand** 
* **$select**
* **includeDeletedItems=true** - Query parameter to return deleted items. This query parameter is only valid when 
targeting a driveItem by ID, and otherwise will be ignored.

- [Sample with query parameters](get_item_metadata_by_id_query_params.bal)

## Get recent DriveItems
Lists a set of items that have been recently used by the `signed in user`. This will include items that are in the 
user's drive as well as the items they have access to from other drives.

- [Sample](get_recent_items.bal)

## Get DriveItems shared with me
Retrieve a collection of `DriveItem` resources that have been shared with the `signed in user` of the OneDrive.

- [Sample](get_shared_items.bal)

## Create new folders in OneDrive
Create a new folder in a Drive with a specified parent item, referred with the parent folder's ID or file system path 
(relative path).

- [ID based addressing sample](create_folder_by_id.bal)

- [Path based addressing sample](create_folder_by_path.bal)

## Update a DriveItem
Update the metadata for a DriveItem in a Drive referring by item ID or file system path (relative path).

- [ID based addressing sample](update_drive_item_by_id.bal)

- [Path based addressing sample](update_drive_item_by_path.bal)

**Note:** <br/>
* Item update does not work when item is open in browser (On editing view)
https://stackoverflow.com/questions/50057662/not-able-to-update-file-stream-through-microsoft-graph-sdk-when-file-is-open-in

* The set of exact fields which can be updated is not provided in the docs. 
If we try to update facets which are not related to the current resource (eg: if the resource is a file and we send 
folder facet it gives an error) error occurs.

## Delete a DriveItem
Delete a DriveItem in a Drive by using it's item ID or file system path (relative path).

- [ID based addressing sample](delete_drive_item.by_id.bal)

- [Path based addressing sample](delete_drive_item.by_path.bal)

## Restore DriveItem
Restore a DriveItem that has been deleted and is currently in the recycle bin.

- [Sample](restore_drive_item.bal)

## Copy a DriveItem
Asynchronously creates a copy of a DriveItem (including any children), under a new parent item or at the same location 
with a new name.

- [ID based addressing sample](copy_drive_item_by_id.bal)

- [Path based addressing sample](copy_drive_item_by_path.bal)

## Download file
Download the contents of the primary stream (file) of a DriveItem using item ID or it's file system path (relative path). 

- [ID based addressing sample](download_file_by_id.bal)

- [Path based addressing sample](download_file_by_path.bal)

**Note:** <br/> 
* Only DriveItems with the file property can be downloaded.

## Upload a small file to a certain location in OneDrive
Upload a new file to the Drive.

- [ID based addressing sample](upload_file_to_parent_id.bal)

- [Path based addressing sample](upload_file_to_parent_path.bal)

**Note:** <br/>
* This method only supports files up to 4MB in size.

## Replace file
Update the contents of an existing file in the Drive.

- [ID based addressing sample](replace_file_using_id.bal)

- [Path based addressing sample](replace_file_using_path.bal)

**Note:** <br/>
* The file used for replacing must be of the same media type as the file which will be replaced.
* This method only supports files up to 4MB in size.

## Upload a large file to a certain location in OneDrive
Upload files up to the maximum file size. 

- [Sample](upload_large_file.bal)

**Note:** <br/> 
* Maximum bytes in any given request should be less than 60 MiB.
* If the file is fragmented into into multiple byte ranges, the size of each byte range MUST be a multiple of 320 KiB 
(327,680 bytes). You can use the constant `ondedrive:DEFAULT_FRAGMENT_SIZE` to easily obtain a multiple of 320 KiB.

## Search DriveItems
Search the hierarchy of items for items matching a query. You can search within a folder hierarchy, a whole drive, or 
files shared with the current user.

- [Sample](search_drive_items.bal)

**Note:** <br/>
* Supports the **$expand**, **$select**, **$skipToken**, **$top**, and **$orderby** OData query parameters to customize 
the response.
* You can use the **$top** query parameter to specify the number of items in the page.
* Find more on Odata query parameters here: https://docs.microsoft.com/en-us/onedrive/developer/rest-api/concepts/optional-query-parameters?view=odsp-graph-online

## Get a sharable link for a DriveItem
Create a new sharing link if the specified link type doesn't already exist for the calling application. If a sharing 
link of the specified type already exists for the app, the existing sharing link will be returned.

- [ID based addressing sample](get_sharable_link_from_id.bal)

- [Path based addressing sample](get_sharable_link_from_path.bal)

## Get metadata for a shared DriveItem
Access a shared DriveItem by using sharing URL.

- [Sample](get_shared_drive_item.bal)

## Send sharing invitation via emails
Sends a sharing invitation for a DriveItem. A sharing invitation provides permissions to the recipients and optionally 
sends them an email with a sharing link.

- [ID based addressing sample](send_sharing_invitation_by_id.bal)

- [Path based addressing sample](send_sharing_invitation_by_path.bal)

**Note:** <br/>
* OneDrive personal accounts cannot create or modify permissions on the root DriveItem.