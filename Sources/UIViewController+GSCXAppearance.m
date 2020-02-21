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
  // In light mode, the scanner's user interface is dark to provide contrast, and vice versa. So the
  // text needs to be white in light mode and black in dark mode.
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      return [UIColor blackColor];
    }
  }
  return [UIColor whiteColor];
}

- (UIColor *)gscx_backgroundColorForCurrentAppearance {
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      return [UIColor whiteColor];
    }
  }
  return [UIColor blackColor];
}

- (UIBlurEffectStyle)gscx_blurEffectStyleForCurrentAppearance {
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      return UIBlurEffectStyleExtraLight;
    }
  }
  // Only light mode existed before iOS 13. Dark is the high contrast style for light mode.
  return UIBlurEffectStyleDark;
}
@end
