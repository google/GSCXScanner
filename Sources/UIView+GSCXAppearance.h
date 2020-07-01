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
 * An analogous version of methods from @c UIViewController+GSCXAppearance for pure @c UIView
 * instances. Provides colors or sets properties so views in the overlay window contrast with the
 * application window. They are dark when the application is light (which is the only mode before
 * iOS 13) and light when the application is dark.
 */
@interface UIView (GSCXAppearance)

/**
 * Sets the value of @c overrideUserInterfaceStyle for overlay view controllers for the current
 * appearance. Before iOS 13, apperance doesn't exist, so this is a no-op.
 */
- (void)gscx_setOverrideUserInterfaceStyleForCurrentApperance;

@end

NS_ASSUME_NONNULL_END
