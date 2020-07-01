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

NS_ASSUME_NONNULL_BEGIN

/**
 * The value of @c accessibilityHint when a @c GSCXScannerIssueExpandableTableViewHeader instance is
 * collapsed, and toggling the button expands it.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerIssueExpandableTableViewHeaderExpandHint;

/**
 * The value of @c accessibilityHint when a @c GSCXScannerIssueExpandableTableViewHeader instance is
 * expanded, and toggling the button collapses it.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerIssueExpandableTableViewHeaderCollapseHint;

/**
 * The name of the custom accessibility action expanding the section.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerIssueExpandableTableViewHeaderExpandActionName;

/**
 * The name of the custom accessibility action collapsing the section.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerIssueExpandableTableViewHeaderCollapseActionName;

/**
 * Invoked when the expand button of a @c GSCXScannerIssueExpandableTableViewHeader instance is
 * toggled.
 *
 * @param isExpanded @c YES if the header is now expanded, @c NO otherwise.
 */
typedef void (^GSCXScannerIssueExpandableTableViewHeaderBlock)(BOOL isExpanded);

/**
 * Displays a title and icon. The icon represents whether the header is expanded or collapsed.
 * Tapping anywhere on the header initially expands the section, displaying all rows. Tapping on the
 * header again collapses all rows. Tapping on header triggers the
 * @c expandButtonToggled callback. Users can use custom accessibility actions or accessibility
 * activate to expand or collapse the section using assistive technologies.
 */
@interface GSCXScannerIssueExpandableTableViewHeader : UITableViewHeaderFooterView

/**
 * @c YES if this section can be expanded, @c NO otherwise. Setting this value shows or hides @c
 * expandButton and adds or removes custom accessibility actions. Defaults to @c YES. Setting @c
 * expandable to @c NO sets @c expanded to @c NO if it is not already.
 */
@property(assign, nonatomic, getter=isExpandable) BOOL expandable;

/**
 * @c YES if this section is expanded, @c NO otherwise. Setting this value changes @c expandIcon
 * to the corresponding state. @c expanded cannot be @c YES when @c expandable is @c NO.
 */
@property(assign, nonatomic, getter=isExpanded) BOOL expanded;

/**
 * Displays the state of @c expanded. When the header is collapsed, @c expandIcon displays an expand
 * icon. When the header is expanded, @c expandIcon displays a collapse icon. Hidden when @c
 * expandable is @c NO. The owner is responsible for styling this icon.
 */
@property(strong, nonatomic, readonly) UIButton *expandIcon;

/**
 * Invoked when the user toggles the header or when @c expanded is set to @c NO because
 * @c expandable was set to @c NO.
 */
@property(copy, nonatomic, nullable)
    GSCXScannerIssueExpandableTableViewHeaderBlock expandHeaderToggled;

@end

NS_ASSUME_NONNULL_END
