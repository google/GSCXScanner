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

#import "UIViewController+GSCXAppearance.h"

@implementation UIViewController (GSCXAppearance)

- (UIColor *)gscx_textColorForCurrentAppearance {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
  if (@available(iOS 13.0, *)) {
    // In iOS 13, the overlay's window overrideUserInterfaceStyle is set, which propagates to all
    // child view controllers. The default colors can be used.
    return [UIColor labelColor];
  }
#endif
  // In iOS 12 and before, dark mode doesn't exist. The APIs exist in iOS 12, but there is no way
  // to set them. So the overlay should always use dark mode, because the application always uses
  // light mode.
  return [UIColor whiteColor];
}

- (UIColor *)gscx_backgroundColorForCurrentAppearance {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
  if (@available(iOS 13.0, *)) {
    return [UIColor systemBackgroundColor];
  }
#endif
  return [UIColor blackColor];
}

- (UIBlurEffectStyle)gscx_blurEffectStyleForCurrentAppearance {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
  if (@available(iOS 13.0, *)) {
    // Only light mode existed before iOS 13. The API existed on iOS 12, but it is impossible to
    // change it. Both the application and overlay windows would return UIUserInterfaceStyleLight.
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
      return UIBlurEffectStyleExtraLight;
    }
  }
#endif
  return UIBlurEffectStyleDark;
}

- (void)gscx_setOverrideUserInterfaceStyleForCurrentApperance {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
  if (@available(iOS 13.0, *)) {
    self.overrideUserInterfaceStyle =
        (UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
            ? UIUserInterfaceStyleLight
            : UIUserInterfaceStyleDark;
  }
#endif
}

@end
