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

#import "GSCXScannerIssueExpandableTableViewDelegate.h"

#import "GSCXScannerIssueExpandableTableViewCell.h"
#import "GSCXScannerIssueExpandableTableViewHeader.h"
#import "GSCXUtils.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXScannerIssueExpandableTableViewCellReuseIdentifier =
    @"kGSCXScannerIssueExpandableTableViewCellReuseIdentifier";

NSString *const kGSCXScannerIssueExpandableTableViewHeaderReuseIdentifier =
    @"kGSCXScannerIssueExpandableTableViewHeaderReuseIdentifier";

/**
 * The error displayed when @c GSCXScannerIssueExpandableTableViewDelegate dequeues a cell that is
 * of the wrong type.
 */
static NSString *const kGSCXScannerIssueExpandableTableViewDelegateIncorrectCellClassError =
    @"Error in GSCXScannerIssueExpandableTableViewDelegate: cell must be of type "
    @"GSCXScannerIssueExpandableTableViewCell";

/**
 * The error displayed when @c GSCXScannerIssueExpandableTableViewDelegate dequeues a header that is
 * of the wrong type.
 */
static NSString *const kGSCXScannerIssueExpandableTableViewDelegateIncorrectHeaderClassError =
    @"Error in GSCXScannerIssueExpandableTableViewDelegate: header must be of type "
    @"GSCXScannerIssueExpandableTableViewHeader";

@interface GSCXScannerIssueExpandableTableViewDelegate ()

/**
 * The sections to display in the table view.
 */
@property(copy, nonatomic, readonly) NSArray<GSCXScannerIssueTableViewSection *> *sections;

/**
 * Invoked when a user taps a row in the table view.
 */
@property(copy, nonatomic) GSCXScannerIssueExpandableTableViewDelegateSelectionBlock selectionBlock;

/**
 * The text color for cells. Defaults to @c whiteColor.
 */
@property(strong, nonatomic) UIColor *textColor;

/**
 * The background color for cells. Defaults to @c blackColor.
 */
@property(strong, nonatomic) UIColor *backgroundColor;

@end

@implementation GSCXScannerIssueExpandableTableViewDelegate

- (instancetype)initWithSections:(NSArray<GSCXScannerIssueTableViewSection *> *)sections
                  selectionBlock:
                      (GSCXScannerIssueExpandableTableViewDelegateSelectionBlock)selectionBlock {
  self = [super init];
  if (self) {
    _sections = [sections copy];
    _selectionBlock = selectionBlock;
    _textColor = [UIColor whiteColor];
    _backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)registerClassesForReuseOnTableView:(UITableView *)tableView {
  [tableView registerClass:[GSCXScannerIssueExpandableTableViewCell class]
      forCellReuseIdentifier:kGSCXScannerIssueExpandableTableViewCellReuseIdentifier];
  [tableView registerClass:[GSCXScannerIssueExpandableTableViewHeader class]
      forHeaderFooterViewReuseIdentifier:kGSCXScannerIssueExpandableTableViewHeaderReuseIdentifier];
}

- (void)setTextColor:(UIColor *)textColor
     backgroundColor:(UIColor *)backgroundColor
         onTableView:(UITableView *)tableView {
  self.textColor = textColor;
  self.backgroundColor = backgroundColor;
  for (GSCXScannerIssueExpandableTableViewCell *cell in tableView.visibleCells) {
    GTX_ASSERT([cell isKindOfClass:[GSCXScannerIssueExpandableTableViewCell class]],
               kGSCXScannerIssueExpandableTableViewDelegateIncorrectCellClassError);
    cell.backgroundColor = self.backgroundColor;
    for (UIView *subview in cell.suggestionStack.arrangedSubviews) {
      if (![subview isKindOfClass:[UILabel class]]) {
        continue;
      }
      UILabel *label = (UILabel *)subview;
      label.textColor = self.textColor;
    }
  }
  for (NSInteger i = 0; i < [self numberOfSectionsInTableView:tableView]; i++) {
    GSCXScannerIssueExpandableTableViewHeader *header =
        (GSCXScannerIssueExpandableTableViewHeader *)[tableView headerViewForSection:i];
    if (header == nil) {
      // There is no way to access only the visible headers. nil represents a non-visible header,
      // so it is skipped.
      continue;
    }
    GTX_ASSERT([header isKindOfClass:[GSCXScannerIssueExpandableTableViewHeader class]],
               kGSCXScannerIssueExpandableTableViewDelegateIncorrectHeaderClassError);
    header.textLabel.textColor = self.textColor;
    [header.expandIcon setTintColor:self.textColor];
  }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GSCXScannerIssueExpandableTableViewCell *cell = [tableView
      dequeueReusableCellWithIdentifier:kGSCXScannerIssueExpandableTableViewCellReuseIdentifier];
  GTX_ASSERT([cell isKindOfClass:[GSCXScannerIssueExpandableTableViewCell class]],
             kGSCXScannerIssueExpandableTableViewDelegateIncorrectCellClassError);
  if (![cell isKindOfClass:[GSCXScannerIssueExpandableTableViewCell class]]) {
    NSLog(kGSCXScannerIssueExpandableTableViewDelegateIncorrectCellClassError);
    return nil;
  }
  cell.accessibilityIdentifier = [GSCXScannerIssueExpandableTableViewDelegate
      gscx_accessibilityIdentifierForRowAtIndexPath:indexPath];
  cell.backgroundColor = self.backgroundColor;
  GSCXScannerIssueTableViewRow *row = self.sections[indexPath.section].rows[indexPath.row];
  [self gscx_addSuggestionsToCell:cell fromRow:row];
  [cell setNeedsUpdateConstraints];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return kGSCXMinimumTouchTargetSize;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return (NSInteger)[self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.sections[section].expanded ? [self.sections[section] numberOfRows] : 0;
}

#pragma mark - UITableViewDelegate

- (nullable UITableViewHeaderFooterView *)tableView:(UITableView *)tableView
                             viewForHeaderInSection:(NSInteger)section {
  GSCXScannerIssueExpandableTableViewHeader *header =
      [tableView dequeueReusableHeaderFooterViewWithIdentifier:
                     kGSCXScannerIssueExpandableTableViewHeaderReuseIdentifier];
  GTX_ASSERT([header isKindOfClass:[GSCXScannerIssueExpandableTableViewHeader class]],
             kGSCXScannerIssueExpandableTableViewDelegateIncorrectHeaderClassError);
  if (![header isKindOfClass:[GSCXScannerIssueExpandableTableViewHeader class]]) {
    NSLog(kGSCXScannerIssueExpandableTableViewDelegateIncorrectHeaderClassError);
    return nil;
  }
  header.accessibilityIdentifier = [GSCXScannerIssueExpandableTableViewDelegate
      gscx_accessibilityIdentifierForHeaderInSection:section];
  [self gscx_setTextOfHeader:header forSection:self.sections[section]];
  [self gscx_setExpandFlagsOfHeader:header
                         forSection:self.sections[section]
                            atIndex:section
                          tableView:tableView];
  [header setNeedsUpdateConstraints];
  return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GSCXScannerIssueTableViewRow *row = self.sections[indexPath.section].rows[indexPath.row];
  self.selectionBlock(row.originalResult, row.originalElementIndex);
}

- (void)tableView:(UITableView *)tableView
    willDisplayHeaderView:(UIView *)view
               forSection:(NSInteger)section {
  GTX_ASSERT([view isKindOfClass:[GSCXScannerIssueExpandableTableViewHeader class]],
             kGSCXScannerIssueExpandableTableViewDelegateIncorrectHeaderClassError);
  GSCXScannerIssueExpandableTableViewHeader *header =
      (GSCXScannerIssueExpandableTableViewHeader *)view;
  header.textLabel.textColor = self.textColor;
  [header.expandIcon setTintColor:self.textColor];
}

#pragma mark - Private

/**
 * Adds a label to @c cell.suggestionStack with @c text if @c text is not nil.
 *
 * @param text The text to add to @c cell, if it exists.
 * @param cell The cell to add the text to.
 */
- (void)gscx_addLabelWithTextIfNonnull:(nullable NSString *)text
                                toCell:(GSCXScannerIssueExpandableTableViewCell *)cell {
  if (text == nil) {
    return;
  }
  UILabel *label = [[UILabel alloc] init];
  label.text = text;
  label.numberOfLines = 0;
  label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  label.textColor = self.textColor;
  [cell.suggestionStack addArrangedSubview:label];
}

/**
 * Adds text describing each suggestion in @c row to @c cell. Removes previous suggestions, if any.
 *
 * @param cell The cell to add labels to.
 * @param row The row representing @c cell.
 */
- (void)gscx_addSuggestionsToCell:(GSCXScannerIssueExpandableTableViewCell *)cell
                          fromRow:(GSCXScannerIssueTableViewRow *)row {
  for (UIView *subview in cell.suggestionStack.subviews) {
    [subview removeFromSuperview];
  }
  [self gscx_addLabelWithTextIfNonnull:row.rowTitle toCell:cell];
  [self gscx_addLabelWithTextIfNonnull:row.rowSubtitle toCell:cell];
  for (NSUInteger i = 0; i < [row.suggestionTitles count]; i++) {
    [self gscx_addLabelWithTextIfNonnull:row.suggestionTitles[i] toCell:cell];
    [self gscx_addLabelWithTextIfNonnull:row.suggestionContents[i] toCell:cell];
  }
}

/**
 * Sets the text and accessibility properties of @c header for the data in @c section.
 *
 * @param header The header to set the text of.
 * @param section The section representing @c header.
 */
- (void)gscx_setTextOfHeader:(GSCXScannerIssueExpandableTableViewHeader *)header
                  forSection:(GSCXScannerIssueTableViewSection *)section {
  header.textLabel.text =
      [NSString stringWithFormat:@"%@ (%ld)", section.title, (long)[section numberOfSuggestions]];
  if (section.numberOfSuggestions == 0) {
    header.accessibilityLabel =
        [NSString stringWithFormat:@"%@ with no suggestions", section.title];
  } else if (section.numberOfSuggestions == 1) {
    header.accessibilityLabel = [NSString stringWithFormat:@"%@ with 1 suggestion", section.title];
  } else {
    header.accessibilityLabel =
        [NSString stringWithFormat:@"%@ with %ld suggestions", section.title,
                                   (long)[section numberOfSuggestions]];
  }
}

/**
 * Sets the properties relating to expansion on @c header.
 *
 * @param header The header to set the expansion properties of.
 * @param section The section representing @c header.
 * @param sectionIndex The index of @c section.
 * @param tableView The table view displaying the header.
 */
- (void)gscx_setExpandFlagsOfHeader:(GSCXScannerIssueExpandableTableViewHeader *)header
                         forSection:(GSCXScannerIssueTableViewSection *)section
                            atIndex:(NSInteger)sectionIndex
                          tableView:(UITableView *)tableView {
  header.expanded = section.expanded;
  header.expandable = section.numberOfSuggestions == 0 ? NO : YES;
  __weak __typeof__(self) weakSelf = self;
  __weak __typeof__(tableView) weakTableView = tableView;
  header.expandHeaderToggled = ^(BOOL isExpanded) {
    __typeof__(self) strongSelf = weakSelf;
    __typeof__(tableView) strongTableView = weakTableView;
    if (strongSelf == nil || strongTableView == nil) {
      return;
    }
    strongSelf.sections[sectionIndex].expanded = isExpanded;
    UITableViewRowAnimation animation = UIAccessibilityIsReduceMotionEnabled()
                                            ? UITableViewRowAnimationNone
                                            : UITableViewRowAnimationFade;
    [strongTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                   withRowAnimation:animation];
  };
}

/**
 * Returns the accessibility identifier for the header view in the given section.
 *
 * @param section The index of the section of the header to get the accessibility identifier of.
 * @return The accessibility identifier for the header view in @c section.
 */
+ (NSString *)gscx_accessibilityIdentifierForHeaderInSection:(NSInteger)section {
  return [NSString
      stringWithFormat:@"GSCXScannerIssueExpandableTableViewDelegate_Header_%ld", (long)section];
}

/**
 * Returns the accessibility identifier for the row at the given index path.
 *
 * @param indexPath The index path of the row.
 * @return The accessibility identifier for the row at @c indexPath.
 */
+ (NSString *)gscx_accessibilityIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [NSString stringWithFormat:@"GSCXScannerIssueExpandableTableViewDelegate_Row_%ld_%ld",
                                    (long)indexPath.section, (long)indexPath.row];
}

@end

NS_ASSUME_NONNULL_END
