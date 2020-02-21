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

#import "GSCXSwizzledMethodNotifier.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "UIApplication+GSCXSwizzling.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXSwizzledMethodNotifier ()

/**
 * The observers for -[UIApplication sendEvent:].  The key is the object observing the action and
 * the value is a block called when sendEvent: occurs. The key is stored weakly. If the key is
 * deallocated, the key-value pair is removed from the table.
 */
@property(strong, nonatomic) NSMapTable<id, void (^)(UIEvent *)> *sendEventObservers;

@end

@implementation GSCXSwizzledMethodNotifier

+ (instancetype)sharedInstance {
  static GSCXSwizzledMethodNotifier *notifier = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    notifier = [[GSCXSwizzledMethodNotifier alloc] initGSCXPrivate];
  });
  return notifier;
}

- (void)addSendEventObserver:(id)observer withBlock:(void (^)(UIEvent *event))block {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    self.sendEventObservers = [NSMapTable weakToStrongObjectsMapTable];
    // Swizzle here instead of +[UIApplication load] to prevent slowing down app startup.
    [GSCXSwizzledMethodNotifier _swizzleClass:[UIApplication class]
                                     selector:@selector(sendEvent:)
                                 withSelector:@selector(gscx_sendEvent:)];
  });
  GTX_ASSERT(![self.sendEventObservers objectForKey:observer],
             @"Cannot register the same object as an observer for the same method twice.");
  [self.sendEventObservers setObject:block forKey:observer];
}

- (void)removeSendEventObserver:(id)observer {
  [self.sendEventObservers removeObjectForKey:observer];
}

- (void)sendEvent:(UIEvent *)event {
  for (id key in self.sendEventObservers) {
    [self.sendEventObservers objectForKey:key](event);
  }
}

#pragma mark - Private

/**
 * Initializes a @c GSCXSwizzledMethodNotifier instance. This method is needed because @c init is
 * marked as unavailable so other classes cannot construct it, but that causes @c
 * GSCXSwizzledMethodNotifier not to be able to call @c init, either.
 *
 * @return An initialized @c GSCXSwizzledMethodNotifier instance.
 */
- (instancetype)initGSCXPrivate {
  self = [super init];
  return self;
}

/**
 * Swizzles the given selector for the given class with the implementation of a different selector.
 * If the class inherits the method implementation from its superclass but does not implement it
 * itself, the new implementation is added to the subclass without affecting the superclass
 * implementation. This prevents accidentally swizzling the wrong class' method implementation.
 *
 * @param classToSwizzle The class on which to swizzle the methods.
 * @param originalSelector The selector of the method implementation to swap with the new
 * implementation.
 * @param newSelector The selector of the method implementation to swap the original implementation
 * with.
 */
+ (void)_swizzleClass:(Class)classToSwizzle
             selector:(SEL)originalSelector
         withSelector:(SEL)newSelector {
  Method originalMethod = class_getInstanceMethod(classToSwizzle, originalSelector);
  Method newMethod = class_getInstanceMethod(classToSwizzle, newSelector);
  IMP originalImplementation = method_getImplementation(originalMethod);
  IMP newImplementation = method_getImplementation(newMethod);
  BOOL didAdd = class_addMethod(classToSwizzle, originalSelector, newImplementation,
                                method_getTypeEncoding(newMethod));
  if (didAdd) {
    class_replaceMethod(classToSwizzle, newSelector, originalImplementation,
                        method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, newMethod);
  }
}

@end

NS_ASSUME_NONNULL_END
