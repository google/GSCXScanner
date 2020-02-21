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

#import "GSCXResultsWindowCoordinating.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @c GSCXScannerWindowCoordinator is a concrete implementation of @c GSCXResultsWindowCoordinating.
 * In external targets, @c GSCXScannerWindowCoordinator presents the results window in front of the
 * overlay. In internal targets, the scanner can be configured to present the results window in
 * front of or behind the overlay but in front of the application window. When placed behind the
 * overlay, the perform scan button is still visible, so users can scan the results UI, presenting
 * another results UI. These results UIs are treated like a stack: dismissing one presents the
 * previous one, until the last one is dismissed and the old key window is presented.
 */
@interface GSCXScannerWindowCoordinator : NSObject <GSCXResultsWindowCoordinating>

+ (instancetype)init NS_UNAVAILABLE;

/**
 * Constructs a @c GSCXScannerWindowCoordinator instance. This instance presents
 * results windows in front of the overlay window.
 */
+ (instancetype)coordinator;

/**
 * The window level for the scanner windows, used to ensure the scanner windows appear above
 * application windows. @c UIWindowLevel instances are not compile time constants, so this cannot be
 * a global constant.
 */
+ (UIWindowLevel)windowLevel;

@end

NS_ASSUME_NONNULL_END
