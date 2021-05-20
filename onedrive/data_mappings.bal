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

isolated function convertToDriveItem(map<json> sourceDriveItemObject) returns DriveItem|error {
    DriveItem convertedItem = check sourceDriveItemObject.cloneWithType(DriveItem);
    convertedItem.downloadUrl = let var url = sourceDriveItemObject["@microsoft.graph.downloadUrl"] in url is string ? 
        url : EMPTY_STRING;
    return convertedItem;
}

isolated function convertToDriveItemArray(json[] sourceDriveItemObject) returns DriveItem[]|error {
    DriveItem[] driveItems = [];
    foreach json item in sourceDriveItemObject {
        DriveItem convertedItem = check convertToDriveItem(<map<json>>item);
        driveItems.push(convertedItem);
    }
    return driveItems;
}

isolated function mapItemInfoToJson(ItemInfo? info) returns json|error {
    json fileInfo = check info?.fileSystemInfo.cloneWithType(json);
    return {
        description: let var desc = info?.description in desc is string ? desc : (), 
        fileSystemInfo: fileInfo,
        name: let var filename = info?.name in filename is string ? filename : (),
        ["@microsoft.graph.conflictBehavior"]: let var behaviour = info?.conflictResolutionBehaviour in behaviour is 
            ConflictResolutionBehaviour ? behaviour.toString() : ()
    };
}
