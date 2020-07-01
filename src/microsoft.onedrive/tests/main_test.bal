// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/config;
import ballerina/test;

// Create the Microsoft Graph Client configuration by reading the config file.
MicrosoftGraphConfiguration msGraphConfig = {
    baseUrl: config:getAsString("MS_BASE_URL"),
    msInitialAccessToken: config:getAsString("MS_ACCESS_TOKEN"),
    msClientId: config:getAsString("MS_CLIENT_ID"),
    msClientSecret: config:getAsString("MS_CLIENT_SECRET"),
    msRefreshToken: config:getAsString("MS_REFRESH_TOKEN"),
    msRefreshUrl: config:getAsString("MS_REFRESH_URL"),
    trustStorePath: config:getAsString("TRUST_STORE_PATH"),
    trustStorePassword: config:getAsString("TRUST_STORE_PASSWORD"),
    bearerToken: config:getAsString("MS_ACCESS_TOKEN"),
    clientConfig: {
        accessToken: config:getAsString("MS_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("MS_CLIENT_ID"),
            clientSecret: config:getAsString("MS_CLIENT_SECRET"),
            refreshToken: config:getAsString("MS_REFRESH_TOKEN"),
            refreshUrl: config:getAsString("MS_REFRESH_URL")
        }
    }
};

OneDriveClient oneDriveClient = new (msGraphConfig);

@test:Config {}
function testGetURLofItem() {
    Item|error item = oneDriveClient->getItem("Book.xlsx");

    if (item is Item) {
        test:assertEquals(item.name, "Book.xlsx", msg = "Failed to get the Excel workbook.");
    } else {
        test:assertFail(msg = item.message());
    }
}
