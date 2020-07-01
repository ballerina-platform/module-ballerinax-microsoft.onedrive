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

import ballerina/http;
import ballerina/oauth2;
import ballerina/stringutils;

# Microsoft OneDrive Client Object.
public type OneDriveClient client object {
    private http:Client oneDriveClient;

    public function init(MicrosoftGraphConfiguration msGraphConfig) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new ({
            accessToken: msGraphConfig.msInitialAccessToken,
            refreshConfig: {
                clientId: msGraphConfig.msClientId,
                clientSecret: msGraphConfig.msClientSecret,
                refreshToken: msGraphConfig.msRefreshToken,
                refreshUrl: msGraphConfig.msRefreshUrl,
                clientConfig: {
                    secureSocket: {
                        trustStore: {
                            path: msGraphConfig.trustStorePath,
                            password: msGraphConfig.trustStorePassword
                        }
                    }
                }
            }
        });
        http:BearerAuthHandler oauth2Handler = new (oauth2Provider);

        self.oneDriveClient = new (msGraphConfig.baseUrl, {
                auth: {
                    authHandler: oauth2Handler
                },
                secureSocket: {
                    trustStore: {
                        path: msGraphConfig.trustStorePath,
                        password: msGraphConfig.trustStorePassword
                    }
                }
            });
    }

    # Get an item located at the root level of OneDrive.
    # + itemName - name of the item (e.g., Workbook) to be fetched
    # + path - path on OneDrive
    # + return - item from the root if fetching is successful or else returns an error
    public remote function getItem(string itemName, string path = "/") returns @tainted (Item|Error) {
        //Make a GET request and collect the information about the items on the root.
        http:Request request = new;
        http:Response|error response = new;
        http:Client clientObj = self.oneDriveClient;
        if (path == "/") {
            response = clientObj->get("/v1.0/me/drive/root/children", request);
        } else {
            response = clientObj->get("https://graph.microsoft.com/v1.0/me/drive/root:" +
            path + ":/children", request);
        }

        Item resultItem = {};

        if (response is error) {
            return HttpError("Error occurred while accessing the Microsoft Graph API.", response);
        }

        http:Response httpResponse = <http:Response>response;

        //If the request was successful, it will return the details in a JSON response.
        json|error responseJson = httpResponse.getJsonPayload();

        if !(responseJson is map<json>) {
            typedesc<any|error> typeOfResponse = typeof responseJson;
            return TypeConversionError("Invalid response; expected a `map<json>` found " + typeOfResponse.toString());
        }

        map<json> responsePayload = <map<json>>responseJson;

        json|error value = responsePayload.value;

        if !(value is json[]) {
            typedesc<any|error> typeOfValue = typeof value;
            return TypeConversionError("Invalid value; expected a `json[]` found " + typeOfValue.toString());
        }

        json[] itemsArray = <json[]>value;

        //Iterate through the array of items until the specified item is found.
        foreach var item in itemsArray {
            if (item is map<json>) {
                if (stringutils:equalsIgnoreCase(item["name"].toString(), itemName)) {
                    resultItem.id = item["id"].toString();
                    resultItem.name = item["name"].toString();
                    resultItem.webUrl = item["webUrl"].toString();
                    return resultItem;
                }
            } else {
                typedesc<any|error> typeOfResponse = typeof responseJson;
                return TypeConversionError("Invalid response; expected a `map<json>` found " + typeOfResponse.toString());
            }
        }

        return resultItem;
    }
};

# Client Object, which represents an item on Microsoft OneDrive.
# + id - unique identifier for the item
# + name - name of the item
# + webUrl - unique URL for accessing the item via a web browser
public type Item record {
    string id = "";
    string name = "";
    string webUrl = "";
};

# Microsoft Graph client configuration.
# + baseUrl - the Microsoft Graph endpoint URL
# + msInitialAccessToken - initial access token
# + msClientId - Microsoft client identifier
# + msClientSecret - client secret
# + msRefreshToken - refresh token
# + msRefreshUrl - refresh URL
# + trustStorePath - trust store path
# + trustStorePassword - trust store password
# + bearerToken - bearer token
# + clientConfig - OAuth2 direct token configuration
public type MicrosoftGraphConfiguration record {
    string baseUrl;
    string msInitialAccessToken;
    string msClientId;
    string msClientSecret;
    string msRefreshToken;
    string msRefreshUrl;
    string trustStorePath;
    string trustStorePassword;
    string bearerToken;
    oauth2:DirectTokenConfig clientConfig;
};
