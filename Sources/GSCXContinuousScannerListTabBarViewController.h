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

#import "GSCXContinuousScannerListTabBarItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Presents multiple list views. Each list displays the same information but groups accessibility
 * issues differently. Users can switch between the grouping methods using the tab bar.
 */
@interface GSCXContinuousScannerListTabBarViewController : UITabBarController

/**
 * Initializes a @c GSCXContinuousScannerListTabBarViewController instance with the given items.
 *
 * @param items The items to display in the list views and tab bar. Each item contains the sections
 *  in the corresponding list and the title of the tab bar item displaying that list. The tab bar
 *  items are displayed in the order of @c items.
 * @return An initialized @c GSCXContinuousScannerListTabBarViewController instance.
 */
- (instancetype)initWithItems:(NSArray<GSCXContinuousScannerListTabBarItem *> *)items;

@end

NS_ASSUME_NONNULL_END
