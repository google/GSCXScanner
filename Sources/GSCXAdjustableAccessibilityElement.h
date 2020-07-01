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
 * Invoked when a user decrements or increments a @c GSCXAdjustableAccessibilityElement.
 *
 * @param sender The accessibility element invoking the block.
 */
typedef void (^GSCXAdjustableAccessibilityElementBlock)(id sender);

/**
 * An adustable accessibility element that exposes its @c accessibilityDecrement and
 * @c accessibilityIncrement methods as blocks, so users don't need custom subclasses for simple
 * elements.
 */
@interface GSCXAdjustableAccessibilityElement : UIAccessibilityElement

- (instancetype)initWithAccessibilityContainer:(id)container NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXAdjustableAccessibilityElement with the given accessibility container and
 * blocks for decrementing and incrementing. Crashes with an assertion if @c decrementBlock or
 * @c incrementBlock are nil.
 *
 * @param container The accessibility container this object is nested in.
 * @param decrementBlock A block to run when @c accessibilityDecrement is called.
 * @param incrementBlock A block to run when @c accessibilityIncrement is called.
 */
- (instancetype)
    initWithAccessibilityContainer:(id)container
                    decrementBlock:(GSCXAdjustableAccessibilityElementBlock)decrementBlock
                    incrementBlock:(GSCXAdjustableAccessibilityElementBlock)incrementBlock
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
