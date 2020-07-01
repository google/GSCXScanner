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

#import <XCTest/XCTest.h>

#import "GSCXScannerSettingsItem.h"
#import "GSCXScannerSettingsTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The text of the table view cell's label for text items.
 */
static NSString *const kGSCXScannerSettingsItemTextItemText = @"Text Item";

/**
 * The title of the table view cell's button for button items.
 */
static NSString *const kGSCXScannerSettingsItemButtonItemTitle = @"Button Item";

/**
 * The accessibility identifier of the table view cell's button for button items.
 */
static NSString *const kGSCXScannerSettingsItemButtonItemAccessibilityIdentifier =
    @"kGSCXScannerSettingsItemButtonItemAccessibilityIdentifier";

/**
 * The accessibility identifier of the table view cell's switch for switch items.
 */
static NSString *const kGSCXScannerSettingsItemSwitchItemAccessibilityIdentifier =
    @"kGSCXScannerSettingsItemSwitchItemAccessibilityIdentifier";

/**
 * The text of the table view cell's label for switch items.
 */
static NSString *const kGSCXScannerSettingsItemSwitchItemLabel = @"Switch Item";

@interface GSCXScannerSettingsItemTests : XCTestCase
@end

@implementation GSCXScannerSettingsItemTests

- (void)testTextItemWithTextConfiguresCell {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [self gscxtest_assertHasTextItemConfiguredCellCorrectly:cell];
}

- (void)testButtonItemWithTitleConfiguresCell {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [self gscxtest_assertHasButtonItemConfiguredCellCorrectly:cell];
}

- (void)testSwitchItemOffWithTextConfiguresCell {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_switchItemOff] configureTableViewCell:cell];
  [self gscxtest_assertHasSwitchItemOffConfiguredCellCorrectly:cell];
}

- (void)testSwitchItemOnWithTextConfiguresCell {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_switchItemOn] configureTableViewCell:cell];
  [self gscxtest_assertHasSwitchItemOnConfiguredCellCorrectly:cell];
}

- (void)testTextItemWithTextConfiguresCellAfterButtonItem {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [self gscxtest_assertHasTextItemConfiguredCellCorrectly:cell];
}

- (void)testTextItemWithTextConfiguresCellAfterSwitchItemOff {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_switchItemOff] configureTableViewCell:cell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [self gscxtest_assertHasTextItemConfiguredCellCorrectly:cell];
}

- (void)testTextItemWithTextConfiguresCellAfterSwitchItemOn {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_switchItemOn] configureTableViewCell:cell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [self gscxtest_assertHasTextItemConfiguredCellCorrectly:cell];
}

- (void)testButtonItemWithTitleConfiguresCellAfterTextItem {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [self gscxtest_assertHasButtonItemConfiguredCellCorrectly:cell];
}

- (void)testButtonItemWithTitleConfiguresCellAfterSwitchItemOff {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_switchItemOff] configureTableViewCell:cell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [self gscxtest_assertHasButtonItemConfiguredCellCorrectly:cell];
}

- (void)testButtonItemWithTitleConfiguresCellAfterSwitchItemOn {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_switchItemOn] configureTableViewCell:cell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [self gscxtest_assertHasButtonItemConfiguredCellCorrectly:cell];
}

- (void)testSwitchItemOffWithTextConfiguresCellAfterTextItem {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [[self gscxtest_switchItemOff] configureTableViewCell:cell];
  [self gscxtest_assertHasSwitchItemOffConfiguredCellCorrectly:cell];
}

- (void)testSwitchItemOnWithTextConfiguresCellAfterTextItem {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_textItem] configureTableViewCell:cell];
  [[self gscxtest_switchItemOn] configureTableViewCell:cell];
  [self gscxtest_assertHasSwitchItemOnConfiguredCellCorrectly:cell];
}

- (void)testSwitchItemOffWithTextConfiguresCellAfterButtonItem {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [[self gscxtest_switchItemOff] configureTableViewCell:cell];
  [self gscxtest_assertHasSwitchItemOffConfiguredCellCorrectly:cell];
}

- (void)testSwitchItemOnWithTextConfiguresCellAfterButtonItem {
  GSCXScannerSettingsTableViewCell *cell = [self gscxtest_tableViewCell];
  [[self gscxtest_buttonItem] configureTableViewCell:cell];
  [[self gscxtest_switchItemOn] configureTableViewCell:cell];
  [self gscxtest_assertHasSwitchItemOnConfiguredCellCorrectly:cell];
}

#pragma mark - Private

/**
 * Dummy method, needed because the actions for @c buttonItemWithTitle:target:action: and
 * @c switchItemWithLabel:target:action are non-nullable.
 */
- (void)gscxtest_dummyAction:(id)sender {
}

/**
 * @return The default @c GSCXScannerSettingsTableViewCell to configure.
 */
- (GSCXScannerSettingsTableViewCell *)gscxtest_tableViewCell {
  return [[GSCXScannerSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:@""];
}

/**
 * @return A @c GSCXScannerSettingsItemConfiguring displaying text in a table view cell.
 */
- (id<GSCXScannerSettingsItemConfiguring>)gscxtest_textItem {
  return [GSCXScannerSettingsItem textItemWithText:kGSCXScannerSettingsItemTextItemText];
}

/**
 * @return A @c GSCXScannerSettingsItemConfiguring displaying a button in a table view cell.
 */
- (id<GSCXScannerSettingsItemConfiguring>)gscxtest_buttonItem {
  return [GSCXScannerSettingsItem
          buttonItemWithTitle:kGSCXScannerSettingsItemButtonItemTitle
                       target:self
                       action:@selector(gscxtest_dummyAction:)
      accessibilityIdentifier:kGSCXScannerSettingsItemButtonItemAccessibilityIdentifier];
}

/**
 * Constructs a switch settings item that is initially on or initially off.
 *
 * @param isOn @c YES if the switch should start on, @c NO if the switch should start off.
 * @return A @c GSCXScannerSettingsItemConfiguring displaying text and a switch in a table view
 * cell.
 */
- (id<GSCXScannerSettingsItemConfiguring>)gscxtest_switchItemIsOn:(BOOL)isOn {
  return [GSCXScannerSettingsItem
          switchItemWithLabel:kGSCXScannerSettingsItemSwitchItemLabel
                         isOn:isOn
                       target:self
                       action:@selector(gscxtest_dummyAction:)
      accessibilityIdentifier:kGSCXScannerSettingsItemSwitchItemAccessibilityIdentifier];
}

/**
 * @return A @c GSCXScannerSettingsItemConfiguring displaying text and a switch in a table view
 * cell. The switch is initially off.
 */
- (id<GSCXScannerSettingsItemConfiguring>)gscxtest_switchItemOff {
  return [self gscxtest_switchItemIsOn:NO];
}

/**
 * @return A @c GSCXScannerSettingsItemConfiguring displaying text and a switch in a table view
 * cell. The switch is initially on.
 */
- (id<GSCXScannerSettingsItemConfiguring>)gscxtest_switchItemOn {
  return [self gscxtest_switchItemIsOn:YES];
}

/**
 * Asserts that the state of @c cell is correct after configuring it to display text with @c
 * gscxtest_textItem.
 */
- (void)gscxtest_assertHasTextItemConfiguredCellCorrectly:(GSCXScannerSettingsTableViewCell *)cell {
  XCTAssertTrue(cell.button.hidden);
  XCTAssertEqualObjects(cell.textLabel.text, kGSCXScannerSettingsItemTextItemText);
  XCTAssertNil(cell.accessoryView);
}

/**
 * Asserts that the state of @c cell is correct after configuring it to display a button with @c
 * gscxtest_buttonItem.
 */
- (void)gscxtest_assertHasButtonItemConfiguredCellCorrectly:
    (GSCXScannerSettingsTableViewCell *)cell {
  NSString *title = [cell.button attributedTitleForState:UIControlStateNormal].string;
  XCTAssertFalse(cell.button.hidden);
  XCTAssertEqualObjects(title, kGSCXScannerSettingsItemButtonItemTitle);
  XCTAssertNil(cell.textLabel.text);
  XCTAssertNil(cell.accessoryView);
  XCTAssertEqualObjects(cell.button.accessibilityIdentifier,
                        kGSCXScannerSettingsItemButtonItemAccessibilityIdentifier);
}

/**
 * Asserts that the state of @c cell is correct after configuring it to display text and a switch
 * with @c switchItem.
 */
- (void)gscxtest_assertHasSwitchItemConfiguredCellCorrectly:(GSCXScannerSettingsTableViewCell *)cell
                                                       isOn:(BOOL)isOn {
  XCTAssertTrue(cell.button.hidden);
  XCTAssertEqualObjects(cell.textLabel.text, kGSCXScannerSettingsItemSwitchItemLabel);
  XCTAssertNotNil(cell.accessoryView);
  XCTAssert([cell.accessoryView isKindOfClass:[UISwitch class]]);
  XCTAssertEqual([(UISwitch *)cell.accessoryView isOn], isOn);
  XCTAssertEqualObjects(cell.accessoryView.accessibilityIdentifier,
                        kGSCXScannerSettingsItemSwitchItemAccessibilityIdentifier);
}

/**
 * Asserts that the state of @c cell is correct after configuring it to display text and a switch
 * with @c switchItem. The switch must be off.
 */
- (void)gscxtest_assertHasSwitchItemOffConfiguredCellCorrectly:
    (GSCXScannerSettingsTableViewCell *)cell {
  return [self gscxtest_assertHasSwitchItemConfiguredCellCorrectly:cell isOn:NO];
}

/**
 * Asserts that the state of @c cell is correct after configuring it to display text and a switch
 * with @c switchItem. The switch must be on.
 */
- (void)gscxtest_assertHasSwitchItemOnConfiguredCellCorrectly:
    (GSCXScannerSettingsTableViewCell *)cell {
  return [self gscxtest_assertHasSwitchItemConfiguredCellCorrectly:cell isOn:YES];
}

@end

NS_ASSUME_NONNULL_END
