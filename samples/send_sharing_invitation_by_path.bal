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

import ballerina/log;
import ballerina/os;
import ballerinax/microsoft.onedrive;

configurable string & readonly refreshUrl = os:getEnv("TOKEN_ENDPOINT");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("APP_ID");
configurable string & readonly clientSecret = os:getEnv("APP_SECRET");

onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: refreshUrl,
        refreshToken : refreshToken,
        clientId : clientId,
        clientSecret : clientSecret,
        scopes: ["offline_access","https://graph.microsoft.com/Files.ReadWrite.All"]
    }
};
onedrive:Client driveClient = check new(configuration);

public function main() {
    log:printInfo("Send sharing invitation by path");

    string filePathToShare = "<PATH_OF_ITEM_TO_SHARE>";
    onedrive:ItemShareInvitation invitation = {
        roles: ["write"],
        recipients: [
            {
                email: "tishchethya@gmail.com"
            }
        ]
    };

    onedrive:Permission|onedrive:Error sharedPermisson = driveClient->sendSharingInvitationByPath(filePathToShare, 
        invitation);
    if (sharedPermisson is onedrive:Permission) {
        log:printInfo("Shared permission info" + sharedPermisson.toString());
        log:printInfo("Success!");
    } else {
        log:printError(sharedPermisson.message());
    }
}
