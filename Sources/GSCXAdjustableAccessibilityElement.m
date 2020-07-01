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

#import "GSCXAdjustableAccessibilityElement.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXAdjustableAccessibilityElement ()

/**
 * Invoked when @c accessibilityDecrement is called.
 */
@property(copy, nonatomic) GSCXAdjustableAccessibilityElementBlock decrementBlock;

/**
 * Invoked when @c accessibilityIncrement is called.
 */
@property(copy, nonatomic) GSCXAdjustableAccessibilityElementBlock incrementBlock;

@end

@implementation GSCXAdjustableAccessibilityElement

- (instancetype)
    initWithAccessibilityContainer:(id)container
                    decrementBlock:(GSCXAdjustableAccessibilityElementBlock)decrementBlock
                    incrementBlock:(GSCXAdjustableAccessibilityElementBlock)incrementBlock {
  GTX_ASSERT(incrementBlock, @"incrementBlock cannot be nil");
  GTX_ASSERT(decrementBlock, @"decrementBlock cannot be nil");
  self = [super initWithAccessibilityContainer:container];
  if (self) {
    _decrementBlock = decrementBlock;
    _incrementBlock = incrementBlock;
  }
  return self;
}

- (UIAccessibilityTraits)accessibilityTraits {
  return [super accessibilityTraits] | UIAccessibilityTraitAdjustable;
}

- (void)accessibilityDecrement {
  self.decrementBlock(self);
}

- (void)accessibilityIncrement {
  self.incrementBlock(self);
}

@end

NS_ASSUME_NONNULL_END
