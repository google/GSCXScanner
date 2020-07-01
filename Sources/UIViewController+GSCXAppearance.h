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
 * Provides colors for dark and light mode. @c GSCXScanner is meant to contrast with the application
 * so it's more explicit what is part of the original application and what is part of the scanner.
 * In light mode (the only mode before iOS 12), this is light text on a dark background. However, in
 * dark mode, this is dark text on a light background, since the app itself will have light text on
 * a dark background.
 */
@interface UIViewController (GSCXAppearance)

/**
 * @return The appropriate color for the current view controller's appearance, maximizing contrast.
 * Pre iOS 12, defaults to black, because dark mode doesn't exist.
 */
- (UIColor *)gscx_textColorForCurrentAppearance;

/**
 * @return The appropriate color for the curent view controller's appearance, maximizing contrast.
 * Pre iOS 12, defaults to white, because dark mode doesn't exist.
 */
- (UIColor *)gscx_backgroundColorForCurrentAppearance;

/**
 * @return The appropriate @c UIBlurEffectStyle value for the current view controller's appearance,
 * maximizing contrast. Pre iOS 12, defaults to @c UIBlurEffectStyleDark, because dark mode doesn't
 * exist.
 */
- (UIBlurEffectStyle)gscx_blurEffectStyleForCurrentAppearance;

/**
 * Sets the value of @c overrideUserInterfaceStyle for overlay view controllers for the current
 * appearance. Before iOS 13, apperance doesn't exist, so this is a no-op.
 */
- (void)gscx_setOverrideUserInterfaceStyleForCurrentApperance;

@end

NS_ASSUME_NONNULL_END
