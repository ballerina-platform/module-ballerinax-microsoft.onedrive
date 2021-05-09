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
import ballerina/log;
import ballerinax/microsoft.onedrive;

configurable http:OAuth2RefreshTokenGrantConfig & readonly driveOauthConfig = ?;

onedrive:Configuration config = {
    clientConfig : driveOauthConfig
};

onedrive:Client driveClient = check new (config);

public function main() {
    log:printInfo("Delete drive item by item ID");

    string itemId = "<TARGET_ITEM_ID>";

    onedrive:Error? deleteResponse = driveClient->deleteDriveItemById(itemId);
    if (deleteResponse is ()) {
        log:printInfo("Item deleted");
        log:printInfo("Success!");
    } else {
        log:printError(deleteResponse.message());
    }
}
