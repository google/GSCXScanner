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

#import "GSCXScannerSettingsItem.h"

#import "GSCXScannerOverlayViewController.h"
#import "GSCXScannerSettingsBlockItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The amount of padding on button items. This gives the text space between the border of the
 * button.
 */
static const CGFloat kGSCXScannerSettingsItemButtonInset = 4.0;

@implementation GSCXScannerSettingsItem

+ (id<GSCXScannerSettingsItemConfiguring>)textItemWithText:(NSString *)text {
  return [GSCXScannerSettingsBlockItem itemWithBlock:^(GSCXScannerSettingsTableViewCell *cell) {
    cell.button.hidden = YES;
    cell.accessoryView = nil;
    cell.textLabel.text = text;
  }];
}

+ (id<GSCXScannerSettingsItemConfiguring>)buttonItemWithTitle:(NSString *)title
                                                       target:(id)target
                                                       action:(SEL)action
                                      accessibilityIdentifier:
                                          (nullable NSString *)accessibilityIdentifier {
  return [GSCXScannerSettingsBlockItem itemWithBlock:^(GSCXScannerSettingsTableViewCell *cell) {
    // Remove all previously added targets and actions.
    [cell.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [cell.button setTitle:title forState:UIControlStateNormal];
    [cell.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    cell.button.accessibilityIdentifier = accessibilityIdentifier;
    cell.button.backgroundColor = [UIColor grayColor];
    cell.button.layer.cornerRadius = kGSCXSettingsCornerRadius;
    cell.button.clipsToBounds = YES;
    cell.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, kGSCXScannerSettingsItemButtonInset, 0.0,
                                                     kGSCXScannerSettingsItemButtonInset);
    cell.button.hidden = NO;
    cell.textLabel.text = nil;
    cell.accessoryView = nil;
  }];
}

+ (id<GSCXScannerSettingsItemConfiguring>)switchItemWithLabel:(NSString *)labelText
                                                         isOn:(BOOL)isOn
                                                       target:(id)target
                                                       action:(SEL)action
                                      accessibilityIdentifier:
                                          (nullable NSString *)accessibilityIdentifier {
  return [GSCXScannerSettingsBlockItem itemWithBlock:^(GSCXScannerSettingsTableViewCell *cell) {
    cell.button.hidden = YES;
    UISwitch *accessoryView = [[UISwitch alloc] init];
    cell.accessoryView = accessoryView;
    accessoryView.accessibilityIdentifier = accessibilityIdentifier;
    accessoryView.on = isOn;
    [accessoryView addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    cell.textLabel.text = labelText;
  }];
}

@end

NS_ASSUME_NONNULL_END
