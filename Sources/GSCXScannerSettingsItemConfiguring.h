//
// Copyright 2019 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

#import "GSCXScannerSettingsTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents an item in the scanner settings page. Items may contain interactive elements or static
 * text. Instances may optionally provide custom styling to the table view cell elements. The data
 * source is allowed to change these styles, but they must call @c configureTableViewCell first or
 * else they will be overwritten.
 */
@protocol GSCXScannerSettingsItemConfiguring <NSObject>

/**
 * Configures the contents of the given table view cell for the current item. If the current item
 * does not use some of the cell's views (for example, the item is static text and does not use the
 * button), it is the responsiblity of this item to hide them.
 *
 * @param tableViewCell A cell in the settings page representing the current item.
 */
- (void)configureTableViewCell:(GSCXScannerSettingsTableViewCell *)tableViewCell;

@end

NS_ASSUME_NONNULL_END
