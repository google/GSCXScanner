//
// Copyright 2020 Google Inc.
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

#import "GSCXScannerIssueTableViewSection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier of the table view in a @c GSCXContinuousScannerListViewController.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerListTableViewAccessibilityIdentifier;

/**
 * Displays a list of scanner issues grouped into sections. The owner is responsible for deciding
 * how issues are grouped. Sections are initially all collapsed. Tapping on a section header expands
 * its rows.
 */
@interface GSCXContinuousScannerListViewController : UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXContinuousScannerListViewController instance with the given sections.
 *
 * @param sections The sections containing issues to display in the list.
 * @return An initialized @c GSCXContinuousScannerListViewController instance.
 */
- (instancetype)initWithSections:(NSArray<GSCXScannerIssueTableViewSection *> *)sections
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
