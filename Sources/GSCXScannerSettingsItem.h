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

NS_ASSUME_NONNULL_BEGIN

/**
 * Encapsulates factory methods to construct @c GSCXScannerSettingsItemConfiguring instances.
 */
@interface GSCXScannerSettingsItem : NSObject

/**
 * This class contains factory methods to construct @c GSCXScannerSettingsItemConfiguring instances.
 * You should not construct an instance of this class.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Constructs a @c GSCXScannerSettingsItemConfiguring instance displaying static text.
 *
 * @param text The text to display in the settings page row item.
 * @return A @c GSCXScannerSettingsItemConfiguring instance displaying static text.
 */
+ (id<GSCXScannerSettingsItemConfiguring>)textItemWithText:(NSString *)text;

/**
 * Constructs a @c GSCXScannerSettingsItemConfiguring instance displaying a button.
 *
 * @param title The title of the button.
 * @param target The object that should receive the action when the button is pressed.
 * @param action The selector sent to @c target when the button is pressed. This action is fired on
 * the @c UIControlEventTouchUpInside event.
 * @param accessibilityIdentifier The accessibility identifier of the button. Optional.
 * @return A @c GSCXScannerSettingsItemConfiguring instance displaying a button.
 */
+ (id<GSCXScannerSettingsItemConfiguring>)buttonItemWithTitle:(NSString *)title
                                                       target:(id)target
                                                       action:(SEL)action
                                      accessibilityIdentifier:
                                          (nullable NSString *)accessibilityIdentifier;

/**
 * Constructs a @c GSCXScannerSettingsItemConfiguring instance displaying text and a switch.
 *
 * @param labelText The text to display in the cell's label describing the switch.
 * @param isOn @c YES if the switch should initially be on, @c NO if the switch should initially be
 * off.
 * @param target The object receiving a message when the switch's value is changed.
 * @param action The selector of the message sent to @c target when the switch's value is changed.
 * @param accessibilityIdentifier The accessibility identifier of the switch. Optional.
 * @return A @c GSCXScannerSettingsItemConfiguring instance displaying text and a switch.
 */
+ (id<GSCXScannerSettingsItemConfiguring>)switchItemWithLabel:(NSString *)labelText
                                                         isOn:(BOOL)isOn
                                                       target:(id)target
                                                       action:(SEL)action
                                      accessibilityIdentifier:
                                          (nullable NSString *)accessibilityIdentifier;

@end

NS_ASSUME_NONNULL_END
