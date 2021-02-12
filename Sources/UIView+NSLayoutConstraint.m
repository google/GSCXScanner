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

#import "UIView+NSLayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIView (NSLayoutConstraint)

- (id)gscx_safeAreaLayoutGuide {
  if (@available(iOS 11.0, *)) {
    return self.safeAreaLayoutGuide;
  }
  return self;
}

- (UIEdgeInsets)gscx_safeAreaInsets {
  if (@available(iOS 11.0, *)) {
    return self.safeAreaInsets;
  }
  return UIEdgeInsetsZero;
}

@end

NS_ASSUME_NONNULL_END
