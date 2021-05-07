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

# Represents the possible mimetypes of a file. **Note:** For more information about compatible formats, refer here: 
# https://docs.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_get_content_format?view=odsp-graph-online#query-string-parameters# 
# 
# + MIMETYPE_PDF - Converts the item into PDF format
# + MIMETYPE_JPG - Converts the item into JPG format
# + MIMETYPE_HTML - Converts the item into HTML format
# + MIMETYPE_GLB - Converts the item into GLB format
public enum FileFormat {
    MIMETYPE_PDF = "pdf",
    MIMETYPE_JPG = "jpg",
    MIMETYPE_HTML = "html",
    MIMETYPE_GLB = "glb",
    MIMETYPE_DOCX = "docx"
}

# Represents the conflict resolution behavior for actions in file operations. Default for PUT requests is `REPLACE`
# 
# + FAIL - Fail the operation when a conflict occurs
# + REPLACE - Replace the file content when a conflict occurs
# + RENAME - Rename the file when a conflict occurs
public enum ConflictResolutionBehaviour {
    FAIL = "fail",
    REPLACE = "replace",
    RENAME = "rename"
}

# The type of the link created.
# 
# + VIEW - A view-only sharing link, allowing read-only access
# + EDIT - An edit sharing link, allowing read-write accessharing link, allowing read-only access
# + EMBED - A view-only sharing link that can be used to embed content into a host webpage
public enum LinkType {
    VIEW = "view",
    EDIT = "edit",
    EMBED = "embed"
}

# The scope of the link represented by this permission.
# 
# + ANONYMOUS - Indicates the link is usable by anyone
# + ORGANIZATION - Indicates the link is only usable for users signed into the same tenant
public enum LinkScope {
    ANONYMOUS = "anonymous",
    ORGANIZATION = "organization"
}

# Specify the roles that are to be granted to the recipients of the sharing invitation.
# 
# + READ - Read permission
# + WRITE - Write permission
public enum PermissionRole {
    READ = "read",
    WRITE = "write"
}

# The desired status of the document after the check-in operation is complete.
# 
# + PUBLISHED - The content is published
# + UNSPECIFIED - The status of conteent is unspecified
public enum CheckInOption {
    PUBLISHED = "published",
    UNSPECIFIED = "unspecified"
}

# The default fragment size for obtaining fragments of a file.(To upload as fragment size MUST be a multiple of 320 KiB 
# (327,680 bytes)).
public const DEFAULT_FRAGMENT_SIZE = 327680;

# The maximum fragment size for obtaining fragments of a file. (The maximum bytes in any given request muat be less than 
# 60 MiB (62,914,560 bytes))
public const MAXIMUM_FRAGMENT_SIZE = 62914550;

enum SystemQueryOption {
    EXPAND = "expand",
    SELECT = "select",
    FILTER = "filter",
    COUNT = "count",
    ORDERBY = "orderby",
    SKIP = "skip",
    TOP = "top",
    SEARCH = "search",
    BATCH = "batch",
    FORMAT = "format"
}

enum OpeningCharacters {
    OPEN_BRACKET = "(",
    OPEN_SQURAE_BRACKET = "[",
    OPEN_CURLY_BRACKET = "{",
    SINGLE_QUOTE_O = "'",
    DOUBLE_QUOTE_O = "\""
}

enum ClosingCharacters {
    CLOSE_BRACKET = ")",
    CLOSE_SQURAE_BRACKET = "]",
    CLOSE_CURLY_BRACKET = "}",
    SINGLE_QUOTE_C = "'",
    DOUBLE_QUOTE_C = "\""
}

enum AsyncJob {
    ITEMCOPY = "ItemCopy",
    DOWNLOADURL = "DownloadUrl"
}

enum AsyncJobStatusString {
    NOT_STARTED = "notStarted",
    IN_PROGRESS = "inProgress",
    UPDATING = "updating",
    DELETE_PENDING = "deletePending",
    WAITING = "waiting",
    FAILED = "failed",
    DELETE_FAILED = "deleteFailed"
}

const ASYNCJOB_COMPLETED = "completed";

enum ErrorCode {
    ACCESS_DENIED = "accessDenied",
    ACTIVITY_LIMIT_REACHED = "activityLimitReached"
}

# Constant field `BASE_URL`. Holds the value of the Microsoft graph API's endpoint URL.
const string BASE_URL = "https://graph.microsoft.com/v1.0";

# Error messages
const PAYLOAD_ACCESS_ERROR_MESSAGE = "Error occurred while accessing the JSON payload";

# Path parameters
const LOGGED_IN_USER = "me";
const DRIVE_RESOURCE = "drive";
const ALL_DRIVE_ITEMS = "items";
const ALL_DRIVES = "drives";
const RECENT_ITEMS = "recent";
const SHARED_WITH_LOGGED_IN_USER = "sharedWithMe";
const FOLLOWING_BY_LOGGED_IN_USER = "following";
const DRIVE_ROOT = "root";
const CHILDREN_RESOURCES = "children";
const SHARED_RESOURCES = "shares";
const ANALYTICS_RESOOURCES = "analytics";
const DRIVEITEM_RESOURCE = "driveItem";
const CONTENT_OF_DRIVE_ITEM = "content";
const RESTORE_ACTION = "restore";
const COPY_ACTION = "copy";
const CREATE_LINK_ACTION = "createLink";
const CREATE_UPLOAD_SESSION_ACTION = "createUploadSession";
const INVITE_ACTION = "invite";
const CHECK_IN_ACTION = "checkin";
const CHECK_OUT_ACTION = "checkout";
const FOLLOW_ACTION = "follow";
const UNFOLLOW_ACTION = "unfollow";
const PREVIEW_ACTION = "preview";

# Request Headers
const CONTENT_RANGE = "Content-Range";
const RANGE = "Range";
# Response Headers

# Symbols
const EQUAL_SIGN = "=";
const URL_PREFIX = "u!";
const EMPTY_STRING = "";
const DOLLAR_SIGN = "$";
const UNDERSCORE = "_";
const MINUS_SIGN = "-";
const PLUS_REGEX = "\\+";
const FORWARD_SLASH = "/";
const AMPERSAND = "&";
const QUESTION_MARK = "?";

# Numbers
const ZERO = 0;
const HUNDRED = 100.0;
const REQUEST_TIMEOUT = 180d;
const RETRY_ATTEMPTS = 5;
const RETRY_INTERVAL = 3d;
const BACKOFF_FACTOR = 2.0;
const MAX_WAIT = 20d;
