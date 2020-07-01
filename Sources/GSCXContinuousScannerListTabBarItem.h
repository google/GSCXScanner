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

#import <Foundation/Foundation.h>

#import "GSCXScannerIssueTableViewSection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An item in a @c GSCXContinuousScannerListTabBarViewController.
 */
@interface GSCXContinuousScannerListTabBarItem : NSObject

/**
 * The sections to display in the list view for this tab.
 */
@property(copy, nonatomic, readonly) NSArray<GSCXScannerIssueTableViewSection *> *sections;

/**
 * The title of this tab in the tab bar.
 */
@property(copy, nonatomic, readonly) NSString *title;

/**
 * Initializes a @c GSCXContinuousScannerListTabBarItem instance with the given sections and title.
 *
 * @param sections The sections to display in the list associated with this tab.
 * @param title The title of this tab in the tab bar.
 * @return An initialized @c GSCXContinuousScannerListTabBarItem instance.
 */
- (instancetype)initWithSections:(NSArray<GSCXScannerIssueTableViewSection *> *)sections
                           title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
