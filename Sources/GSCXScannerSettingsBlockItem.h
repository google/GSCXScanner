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

#import "GSCXScannerSettingsItemConfiguring.h"

#import "GSCXScannerSettingsTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A row item in the scanner settings page that is configured by a block.
 */
@interface GSCXScannerSettingsBlockItem : NSObject <GSCXScannerSettingsItemConfiguring>

/**
 * Initializes this instance with the given block to configure the row item in the scanner settings
 * page.
 *
 * @param A block that configures the passed in table view cell.
 */
- (instancetype)initWithBlock:(void (^)(GSCXScannerSettingsTableViewCell *))block;

/**
 * Constructs a @c GSCXScannerSettingsBlockItem instance with the given block to configure the row
 * item in the scanner settings page.
 *
 * @param A block that configures the passed in table view cell.
 */
+ (instancetype)itemWithBlock:(void (^)(GSCXScannerSettingsTableViewCell *))block;

@end

NS_ASSUME_NONNULL_END
