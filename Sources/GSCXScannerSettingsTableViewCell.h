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

NS_ASSUME_NONNULL_BEGIN

/**
 * The minimum distance between the top and button of a settings button and the top and bottom of
 * the enclosing table view cell.
 */
FOUNDATION_EXTERN const CGFloat kGSCXScannerSettingsTableViewCellButtonMargin;

/**
 * The minimum height of a settings button.
 */
FOUNDATION_EXTERN const CGFloat kGSCXScannerSettingsTableViewCellButtonMinimumHeight;

/**
 * The minimum percentage of the table view cell's width that the button's width must be.
 */
FOUNDATION_EXTERN const CGFloat kGSCXScannerSettingsTableViewCellButtonMinimumWidthMultiplier;

/**
 * A row item in the scanner settings page.
 */
@interface GSCXScannerSettingsTableViewCell : UITableViewCell

/**
 * A button that can perform an action. It is the responsibility of the table view's data source to
 * add or remove the button from the cell or register the action the button should perform.
 */
@property(strong, nonatomic) UIButton *button;

@end

NS_ASSUME_NONNULL_END
