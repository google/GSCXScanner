//
// Copyright 2019 Google LLC.
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
 * Centralizes all method swizzling required for monitoring app activity sources. Sources can stop
 * monitoring. However, if stopping monitoring unswizzles the method, this could cause
 * inconsistencies. If a different class swizzles the same method after the source and the source
 * unswizzles the method, the order of implementations would no longer be correct. Never unswizzling
 * solves this. To allow sources to stop monitoring, they do not swizzle directly. Instead, they
 * register and unregister themselves as observers of specific methods in @c
 * GSCXSwizzledMethodNotifier, similar to @c NSNotificationCenter.
 */
@interface GSCXSwizzledMethodNotifier : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * @return The singleton instance of this class.
 */
+ (instancetype)sharedInstance;

/**
 * Adds an object as an observer for -[UIApplication sendEvent:]. An object can only have a single
 * observing block for a single method.
 *
 * @param observer The object observing sendEvent:.
 * @param block A callback to run whenever sendEvent: is called. The parameters to the block are the
 * same as the parameters passed to sendEvent:.
 */
- (void)addSendEventObserver:(id)observer withBlock:(void (^)(UIEvent *event))block;

/**
 * Removes an object as an observer for -[UIApplication sendEvent:]. If the object was not already
 * an observer, does nothing.
 *
 * @param observer The object observing sendEvent: to remove as an observer.
 */
- (void)removeSendEventObserver:(id)observer;

/**
 * Notifies all observers for @c sendEvent:.
 *
 * @param event The parameter passed to the original call to @c sendEvent.
 */
- (void)sendEvent:(UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
