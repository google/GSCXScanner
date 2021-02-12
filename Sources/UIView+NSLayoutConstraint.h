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

// Methods to make working with Autolayout constraints with UIView easier.
@interface UIView (NSLayoutConstraint)

/**
 * Returns the safe area layout guide. On pre-iOS 11, before safeAreaLayoutGuide existed, returns
 * self. TODO: Remove when iOS 10 support is dropped.
 */
@property(nonatomic, readonly) id gscx_safeAreaLayoutGuide;

/**
 * Returns the safe area insets. On pre-iOS 11, before the safe area existed, returns
 * UIEdgeInsetsZero. TODO: Remove when iOS 10 support is dropped.
 */
@property(nonatomic, readonly) UIEdgeInsets gscx_safeAreaInsets;

@end

NS_ASSUME_NONNULL_END
