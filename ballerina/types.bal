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
import ballerinax/'client.config;

# Client configuration details.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    # Configurations related to client authentication
    http:BearerTokenConfig|config:OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_1_1;
|};

# Represents a file, folder, or other item stored in a drive.
#
# + id - The unique identifier of the drive
# + createdDateTime - Date and time of item creation
# + cTag - An eTag for the content of the item. This eTag is not changed if only the metadata is changed. 
#          **Note:** This property is not returned if the item is a folder.
# + eTag - ETag for the item
# + lastModifiedDateTime - Date and time the item was last modified 
# + name - Name of the item
# + size - Size of the item in bytes 
# + webUrl - URL that displays the resource in the browser
# + description - Provides a user-visible description of the item
# + webDavUrl - WebDAV compatible URL for the item 
# + root - If this property is non-null, it indicates that the driveItem is the top-most driveItem in the drive
# + createdBy - Identity of the user, device, or application which created the item 
# + lastModifiedBy - Identity of the user, device, and application which last modified the item
# + fileSystemInfo - File system information on client
# + parentReference - Parent information, if the item has a parent
# + remoteItem - Remote item data, if the item is shared from a drive other than the one being accessed
# + downloadUrl - A URL that can be used to download this file's content. Authentication is not required with this URL. 
# + file - File metadata, if the item is a file
# + folder - Folder metadata, if the item is a folder
# + image - Image metadata, if the item is an image 
# + photo - Photo metadata, if the item is a photo 
# + video - Video metadata, if the item is a video
# + audio - Audio metadata, if the item is an audio file 
# + location - Location metadata, if the item has location data 
# + package - If present, indicates that this item is a package instead of a folder or file
# + publication - Provides information about the published or checked-out state of an item, in locations that support 
#                 such actions
# + deleted - Information about the deleted state of the item
# + shared - Indicates that the item has been shared with others and provides information about the shared state of the 
# + searchResult - Search metadata, if the item is from a search result item
# + sharepointIds - Returns identifiers useful for SharePoint REST compatibility
# + specialFolder - If the current item is also available as a special folder, this facet is returned
# + children - Collection containing Item objects for the immediate children of item
# + versions - The list of previous versions of the item 
# + activities - The list of recent activities that took place on this item
# + permissions - The set of permissions for the item 
# + thumbnails - Collection containing ThumbnailSet objects associated with the item
public type DriveItemData record {
    string id?;
    string createdDateTime?;
    string cTag?;
    string eTag?;
    string lastModifiedDateTime?;
    string name?;
    int size?;
    string webUrl?;
    string description?;
    string webDavUrl?;
    json root?;
    IdentitySet createdBy?;
    IdentitySet lastModifiedBy?;
    FileSystemInfo fileSystemInfo?;
    ItemReference parentReference?;
    DriveItemData remoteItem?;
    string downloadUrl?;
    File file?;
    Folder folder?;
    Image image?;
    Photo photo?;
    Video video?;
    Audio audio?;
    GeoCordinates location?;
    Package package?;
    Publication publication?;
    Deleted deleted?;
    Shared shared?;
    SearchResult searchResult?;
    SharePointId sharepointIds?;
    SpecialFolder specialFolder?;
    // relationships
    DriveItemData[] children?;
    DriveItemVersion[] versions?;
    ItemActivity activities?;
    Permission[] permissions?;
    ThumbnailSet[] thumbnails?;
    // instance annotations
};

# represent a set of identities associated with various events for an item.
#
# + application - The application associated with this action
# + device - The device associated with this action 
# + user - The user associated with this action 
public type IdentitySet record {
    Identity application?;
    Identity device?;
    Identity user?;
};

# Represents an identity of a user, device, or application. 
#
# + displayName - The identity's display name
# + id - Unique identifier for the identity
public type Identity record {
    string displayName?;
    string id?;
};

# Resource that contains properties that are reported by the device's local file system for the local version of an 
# item.
#
# + createdDateTime - The UTC date and time the file was created on a client
# + lastAccessedDateTime - The UTC date and time the file was last accessed 
# + lastModifiedDateTime - The UTC date and time the file was last modified on a client
public type FileSystemInfo record {
    string createdDateTime?;
    string lastAccessedDateTime?;
    string lastModifiedDateTime?;
};

# Provides information necessary to address a DriveItem via the API.
#
# + driveId - Unique identifier of the drive instance that contains the item 
# + driveType - Identifies the type of drive 
# + id - Unique identifier of the item in the drive
# + name - The name of the item being referenced 
# + path - Path that can be used to navigate to the item
# + shareId - A unique identifier for a shared resource that can be accessed via the Shares API
# + sharepointIds - Returns identifiers useful for SharePoint REST compatibility
public type ItemReference record {
    string driveId?;
    string driveType?;
    string id?;
    string name?;
    string path?;
    string shareId?;
    SharePointId sharepointIds?;
};

# Resource that groups file-related data items into a single structure.
#
# + content - A `byte[]` which represents the content of a file
# + mimeType - The MIME type for the file
# + hashes - Hashes of the file's binary content, if available
public type File record {
    byte[] content?;
    string mimeType?;
    Hash hashes?;
};

# Resource that groups available hashes into a single structure for an item.
#
# + crc32Hash - The CRC32 value of the file in little endian (if available)
# + sha1Hash - SHA1 hash for the contents of the file (if available)
# + sha256Hash - SHA256 hash for the contents of the file (if available)
# + quickXorHash - A proprietary hash of the file that can be used to determine if the contents of the file have changed
public type Hash record {
    string crc32Hash?;
    string sha1Hash?;
    string sha256Hash?;
    string quickXorHash?;
};

# Resource that groups folder-related data on an item into a single structure.
#
# + childCount - Number of children contained immediately within this container 
# + view - A collection of properties defining the recommended view for the folder
public type Folder record {|
    int:Unsigned32 childCount?;
    FolderView view?;
|};

# Resource that provides or sets recommendations on the user-experience of a folder.
#
# + sortBy - The method by which the folder should be sorted 
# + sortOrder - Indicates that items should be sorted in descending order. Otherwise, items should be sorted ascending.
# + viewType - The type of view that should be used to represent the folder
public type FolderView record {
    SortBy sortBy?;
    SortOrder sortOrder?;
    ViewType viewType?;
};

# Resource that groups image-related properties into a single structure.
#
# + width - Width of the image, in pixels 
# + height - Height of the image, in pixels
public type Image record {
    int:Unsigned32 width?;
    int:Unsigned32 height?;
};

# Resource that provides photo and camera properties.
#
# + cameraMake - Camera manufacturer 
# + cameraModel - Camera model 
# + exposureDenominator - The denominator for the exposure time fraction from the camera
# + exposureNumerator - The numerator for the exposure time fraction from the camera
# + fNumber - The F-stop value from the camera 
# + focalLength - The focal length from the camera
# + iso - The ISO value from the camera
# + takenDateTime - Represents the date and time the photo was taken
public type Photo record {
    string cameraMake?;
    string cameraModel?;
    float exposureDenominator?;
    float exposureNumerator?;
    float fNumber?;
    float focalLength?;
    int:Unsigned32 iso?;
    string takenDateTime?;
};

# Resource that groups video-related data items into a single structure.
#
# + audioBitsPerSample - Number of audio bits per sample 
# + audioChannels - Number of audio channels
# + audioFormat - Name of the audio format (AAC, MP3, etc.) 
# + audioSamplesPerSecond - Number of audio samples per second
# + bitrate - Bit rate of the video in bits per second
# + duration - Duration of the file in milliseconds
# + fourCC - "Four character code" name of the video format
# + frameRate - Frame rate of the video
# + height - Height of the video, in pixels
# + width - Width of the video, in pixels
public type Video record {
    int:Unsigned32 audioBitsPerSample?;
    int:Unsigned32 audioChannels?;
    string audioFormat?;
    int:Unsigned32 audioSamplesPerSecond?;
    int:Unsigned32 bitrate?;
    int duration?;
    string fourCC?;
    float frameRate?;
    int:Unsigned32 height?;
    int:Unsigned32 width?;
};

# Resource that groups audio-related properties on an item into a single structure.
#
# + album - The title of the album for this audio file 
# + albumArtist - The artist named on the album for the audio file 
# + artist - The performing artist for the audio file 
# + bitrate - Bitrate expressed in kbps 
# + composers - The name of the composer of the audio file 
# + copyright - Copyright information for the audio file 
# + disc - The number of the disc this audio file came from
# + discCount - The total number of discs in this album 
# + duration - Duration of the audio file, expressed in milliseconds 
# + genre - The genre of this audio file
# + hasDrm - Indicates if the file is protected with digital rights management
# + isVariableBitrate - Indicates if the file is encoded with a variable bitrate
# + title - The title of the audio file
# + track - The number of the track on the original disc for this audio file
# + trackCount - The total number of tracks on the original disc for this audio file 
# + year - The year the audio file was recorded
public type Audio record {
    string album?;
    string albumArtist?;
    string artist?;
    int bitrate?;
    string composers?;
    string copyright?;
    int:Unsigned16 disc?;
    int:Unsigned16 discCount?;
    int duration?;
    string genre?;
    boolean hasDrm?;
    boolean isVariableBitrate?;
    string title?;
    int:Unsigned32 track?;
    int:Unsigned32 trackCount?;
    int:Unsigned32 year?;
};

# Resource that provides geographic coordinates and elevation of a location based on metadata contained within the file.
#
# + altitude - The altitude (height), in feet, above sea level for the item
# + latitude - The latitude, in decimal, for the item
# + longitude - he longitude, in decimal, for the item
public type GeoCordinates record {
    float altitude?;
    float latitude?;
    float longitude?;
};

# Resource that indicates if a DriveItem is the top level item in a "package" or a collection of items that should be 
# treated as a collection instead of individual items.
#
# + 'type - A string indicating the type of package
public type Package record {
    string 'type?;
};

# Resource that provides details on the published status of a driveItemVersion or driveItem resource.
#
# + level - The state of publication for this document. Either `published` or `checkout`. 
# + versionId - The unique identifier for the version that is visible to the current caller
public type Publication record {
    PublicationLevel level?;
    string versionId?;
};

# Resource that indicates that the item has been deleted. The presence (non-null) of the resource value indicates that 
# the file was deleted. A null (or missing) value indicates that the file is not deleted.
#
# + state - Represents the state of the deleted item 
public type Deleted record {
    string state?;
};

# Resource that indicates a DriveItem has been shared with others.
#
# + owner - The identity of the owner of the shared item
# + scope - Indicates the scope of how the item is shared: `anonymous`, `organization`, or `users`
# + sharedBy - The identity of the user who shared the item 
# + sharedDateTime - he UTC date and time when the item was shared
public type Shared record {
    IdentitySet owner?;
    string scope?; 
    IdentitySet sharedBy?;
    string sharedDateTime?;
};

# Resource that indicates than an item is the response to a search query.
#
# + onClickTelemetryUrl - A callback URL that can be used to record telemetry information. 
public type SearchResult record {
    string onClickTelemetryUrl?;
};

# Resource that groups the various identifiers for an item stored in a SharePoint site or OneDrive for Business into a 
# single structure.
#
# + listId - The unique identifier (guid) for the item's list in SharePoint 
# + listItemId - An integer identifier for the item within the containing list
# + listItemUniqueId - The unique identifier (guid) for the item within OneDrive for Business or a SharePoint site
# + siteId - The unique identifier (guid) for the item's site collection (SPSite)
# + siteUrl - The SharePoint URL for the site that contains the item
# + tenantId - The unique identifier (guid) for the tenancy
# + webId - The unique identifier (guid) for the item's site (SPWeb)
public type SharePointId record {
    string listId?;
    string listItemId?;
    string listItemUniqueId?;
    string siteId?;
    string siteUrl?;
    string tenantId?;
    string webId?;
};

# Resource that groups special folder-related data items into a single structure.
#
# + name - The unique identifier for this item in the /drive/special collection
public type SpecialFolder record {
    string name?;
};

# Resource that represents a specific version of a DriveItem.
#
# + id - The ID of the version 
# + lastModifiedBy - Identity of the user which last modified the version 
# + lastModifiedDateTime - Date and time the version was last modified 
# + publication - Indicates the publication status of this particular version 
# + size - Indicates the size of the content stream for this version of the item
public type DriveItemVersion record {
    string id?;
    IdentitySet lastModifiedBy?;
    string lastModifiedDateTime?;
    Publication publication?;
    int size?;
    //content: { @odata.type: Edm.Stream },
};

# Resource that provides information about activities that took place on an item or within a container.
#
# + id - The unique identifier of the activity
# + actor - Identity of who performed the action 
# + driveItem - The driveItem that was the target of this activity
# + activityDateTime - Details about when the activity took place 
public type ItemActivity record {
    string id?;
    IdentitySet actor?;
    DriveItemData driveItem?;
    string activityDateTime?;
    //listItem: {@odata.type: microsoft.graph.listItem},
};

# Resource that provides information about a sharing permission granted for a DriveItem resource.
#
# + id - The unique identifier of the permission among all permissions on the item
# + grantedTo - For user type permissions, the details of the users & applications for this permission 
# + grantedToIdentities - For link type permissions, the details of the users to whom permission was granted
# + inheritedFrom - Provides a reference to the ancestor of the current permission, if it is inherited from an ancestor 
# + invitation - Details of any associated sharing invitation for this permission
# + link - Provides the link details of the current permission, if it is a link type permissions
# + roles - The type of permission 
# + shareId - A unique token that can be used to access this shared item via the shares API
public type Permission record {
    string id?;
    IdentitySet grantedTo?;
    IdentitySet[] grantedToIdentities?;
    ItemReference inheritedFrom?;
    ShareInvitation invitation?;
    SharingLink link?;
    string[] roles?;
    string shareId?;
};

#  Resource that groups link-related data items into a single structure.
#
# + application - The app the link is associated with
# + 'type - The type of the link created 
# + scope - The scope of the link represented by this permission. Value `anonymous` indicates the link is usable by 
#           anyone, `organization` indicates the link is only usable for users signed into the same tenant. 
# + webHtml - For `embed` links, this property contains the HTML code for an <iframe> element that will embed the item 
#             in a webpage.
# + webUrl - A URL that opens the item in the browser on the OneDrive website. 
public type SharingLink record {
    Identity application?;
    LinkType 'type?;
    LinkScope scope?;
    string webHtml?;
    string webUrl?;
};

# Resource that groups invitation-related data items into a single structure.
#
# + email - The email address provided for the recipient of the sharing invitation 
# + invitedBy - Provides information about who sent the invitation that created this permission, if that information 
#               is available 
# + signInRequired - If true the recipient of the invitation needs to sign in in order to access the shared item  
public type ShareInvitation record {
    string email?;
    IdentitySet invitedBy?;
    boolean signInRequired?;
};

# Resource which is a keyed collection of thumbnail resources. It is used to represent a set of thumbnails associated 
# with a DriveItem.
#
# + id - The id within the item
# + large - A 1920x1920 scaled thumbnail 
# + medium - A 176x176 scaled thumbnail
# + small - A 48x48 cropped thumbnail 
# + 'source - A custom thumbnail image or the original image used to generate other thumbnails
public type ThumbnailSet record {
    string id?;
    Tumbnail large?;
    Tumbnail medium?;
    Tumbnail small?;
    Tumbnail 'source?;
};

# Resource that represents a thumbnail for an image, video, document, or any item that has a bitmap representation.
#
# + height - The height of the thumbnail, in pixels
# + width - The width of the thumbnail, in pixels 
# + sourceItemId - The unique identifier of the item that provided the thumbnail. This is only available when a folder 
#                  thumbnail is requested.
# + url - The URL used to fetch the thumbnail content
public type Tumbnail record {
    int:Unsigned32 height?;
    int:Unsigned32 width?;
    string sourceItemId?;
    string url?;
};

// *********************************************** Input Record Types **************************************************
# Drive item data.
#
# + name - Name of the item
# + file - File metadata, if the item is a file
# + folder - Folder metadata, if the item is a folder 
# + parentReference - Parent information, if the item has a parent
public type DriveItem record {|
    string name?;
    File file?;
    Folder folder?;
    ParentReference parentReference?;
|};

# Represents necessary metadata in reference to a folder.
#
# + name - The name of the folder
# + folder - Folder metadata, if the item is a folder
# + parentReference - Parent information, if the item has a parent
# + fileSystemInfo - File system information on client
# + conflictResolutionBehaviour - The conflict resolution behaviour
public type FolderMetadata record {|
    string name;
    Folder folder = { };
    ItemReference parentReference?;
    FileSystemInfo fileSystemInfo?;
    ConflictResolutionBehaviour conflictResolutionBehaviour?;
|};

# The reference data for the destination folder where the item will be copied.
#
# + id - ID of the destination folder  
# + driveId - ID of the Drive the destination folder exist
public type ParentReference record {|
    string id;
    string driveId?;
|};

# Resource that defines properties of the sharing link your application is requesting. 
#
# + 'type - The type of sharing link to create. Either `view`, `edit`, or `embed`
# + scope - The scope of link to create. Either `anonymous` or `organization`
# + password - The password of the sharing link that is set by the creator. Optional and OneDrive Personal only.
# + expirationDateTime - A String with format of yyyy-MM-ddTHH:mm:ssZ of DateTime indicates the expiration time of the 
#                        permission 
public type PermissionOptions record {|
    LinkType 'type;
    LinkScope scope?;
    string password?;
    string expirationDateTime?;
|};

# Resource that provide additional data about the file being uploaded and customizing the semantics of the upload 
# operation.
#
# + description - Provides a user-visible description of the item. Only on OneDrive Personal.
# + fileSystemInfo - File system information on client
# + name - The name of the item (filename and extension) 
# + fileSize - Provides an expected file size to perform a quota check prior to upload. Only on OneDrive Personal.
# + conflictResolutionBehaviour - The conflict resolution behaviour
public type UploadMetadata record {|
    int fileSize;
    string name?;
    string description?;
    FileSystemInfo fileSystemInfo?;
    ConflictResolutionBehaviour conflictResolutionBehaviour?;
|};

# Resource that represents necessary information for a sharing invitation.
#
# + requireSignIn - Specifies whether the recipient of the invitation is required to sign-in to view the shared item.
# + sendInvitation - If true, a sharing link is sent to the recipient. Otherwise, a permission is granted directly 
#                    without sending a notification. 
# + roles - Specify the roles that are to be granted to the recipients of the sharing invitation 
# + recipients - A collection of recipients who will receive access and the sharing invitation 
# + message - A plain text formatted message that is included in the sharing invitation. Maximum length 2000 characters.
public type ItemShareInvitation record {|
    boolean requireSignIn = true;
    boolean sendInvitation = false;
    PermissionRole[] roles;
    DriveRecipient[] recipients;
    string message?;
|};

# Resource that represents a person, group, or other recipient to share with using the invite action.
#
# + email - The email address for the recipient, if the recipient has an associated email address 
# + alias - The alias of the domain object, for cases where an email address is unavailable (e.g. security groups)
# + objectId - The unique identifier for the recipient in the directory 
public type DriveRecipient record {|
    string email;
    string alias?;
    string objectId?;
|};

# Resource that contains the values to define a range of bytes.
#
# + startByte - The value of the starting index of bytes  
# + endByte - The value of the ending index of bytes   
public type ByteRange record {|
    int startByte;
    int endByte;
|};

// ***************************************** Other Record Types ********************************************************
# Resource that contains options for Check-In a file.
#
# + comment - A check-in comment that is associated with the version
# + checkInAs - Optional. The status of the document after the check-in operation is complete. 
#               Can be `published` or `unspecified`.
public type CheckInOptions record {|
    string comment;
    CheckInOption checkInAs?;
|};

# Resource that contain defines properties of the embeddable URL your application is requesting.
#
# + page - Optional. Page number of document to start at, if applicable. Specified as string for future use cases 
#          around file types such as ZIP.
# + zoom - Optional. Zoom level to start at, if applicable.
public type PreviewOptions record {|
    string|int page?;
    int zoom?; 
|};

# Resource that represents the embeddable URLs for the preview.
#
# + getUrl - URL suitable for embedding using HTTP GET (iframes, etc.) 
# + postUrl - URL suitable for embedding using HTTP POST (form post, JS, etc.)
# + postParameters - POST parameters to include if using postUrl
public type EmbeddableData record {|
    string getUrl?;
    string postUrl?;
    string postParameters?;
|};

# Resource that provides analytics about activities that took place on an item. This resource is currently only 
# available on SharePoint and OneDrive for Business.
#
# + allTime - Analytics over the item's lifespan 
# + lastSevenDays - Analytics for the last seven days
public type ItemAnalytics record {
    ItemActivityStat allTime?;
    ItemActivityStat lastSevenDays?;
};

# Resource that provides information about activities that took place within an interval of time.
#
# + activities - Exposes the itemActivities represented in this itemActivityStat resource
# + incompleteData - Indicates that the statistics in this interval are based on incomplete data
# + isTrending - Indicates whether the item is "trending"
# + startDateTime - When the interval starts
# + endDateTime - When the interval ends 
# + create - Statistics about the `create` actions in this interval 
# + delete - Statistics about the `edit` actions in this interval 
# + edit - Statistics about the `delete` actions in this interval
# + move - Statistics about the `move` actions in this interval
# + access - Statistics about the `access` actions in this interval
public type ItemActivityStat record {
    ItemActivity[] activities?;
    IncompleteData incompleteData?;
    boolean isTrending?;
    string startDateTime?;
    string endDateTime?;
    ItemActionStat create?;
    ItemActionStat delete?;
    ItemActionStat edit?;
    ItemActionStat move?;
    ItemActionStat access?;
};

# Indicates that a resource was generated with incomplete data. The properties within might provide information about 
# why the data is incomplete.
#
# + missingDataBeforeDateTime - The service does not have source data before the specified time 
# + wasThrottled - Some data was not recorded due to excessive activity
public type IncompleteData record {|
    string missingDataBeforeDateTime;
    boolean wasThrottled;
|};

# Resource that provides aggregate details about an action over a period of time.
#
# + actionCount - The number of times the action took place
# + actorCount - The number of distinct actors that performed the action
public type ItemActionStat record {|
    int:Unsigned32 actionCount;
    int:Unsigned32 actorCount;
|};
