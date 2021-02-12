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
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * Reuse identifier for cells in the expandable list view.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerIssueExpandableTableViewCellReuseIdentifier;

/**
 * Reuse identifier for section headers in the expandable list view.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerIssueExpandableTableViewHeaderReuseIdentifier;

/**
 * Invoked when the user taps a row in a table view managed by a
 * @c GSCXScannerIssueExpandableTableViewDelegate instance.
 *
 * @param result The result containing the element associated with the tapped row.
 * @param issueIndex The index of the element in @c result associated with the tapped row.
 */
typedef void (^GSCXScannerIssueExpandableTableViewDelegateSelectionBlock)(
    GTXHierarchyResultCollection *result, NSInteger issueIndex);

/**
 * Displays a list of sections, each containing rows representing one or more accessibility issues.
 * Initially, the sections display no rows. Tapping on the section header expands the section,
 * displaying all the rows. Tapping on it again collapses it.
 */
@interface GSCXScannerIssueExpandableTableViewDelegate
    : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXScannerIssueExpandableTableViewDelegate with the given sections.
 *
 * @param sections The sections to display in the table view.
 * @param selectionBlock Invoked when a user taps a row in the table view.
 * @return An initialized @c GSCXScannerIssueExpandableTableViewDelegate instance.
 */
- (instancetype)initWithSections:(NSArray<GSCXScannerIssueTableViewSection *> *)sections
                  selectionBlock:
                      (GSCXScannerIssueExpandableTableViewDelegateSelectionBlock)selectionBlock
    NS_DESIGNATED_INITIALIZER;

/**
 * Registers classes for cell and header reuse on @c tableView.
 *
 * @param tableView The table view to register classes for reuse on.
 */
- (void)registerClassesForReuseOnTableView:(UITableView *)tableView;

/**
 * Sets the text and background colors for all headers and cells. Currently visible headers and
 * cells are updated immediately.
 *
 * @param textColor The text color of labels in headers and cells.
 * @param backgroundColor The background color of cells.
 * @param tableView The table view this instance is a delegate of.
 */
- (void)setTextColor:(UIColor *)textColor
     backgroundColor:(UIColor *)backgroundColor
         onTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
