//
// Copyright 2019 Google Inc.
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

#import <XCTest/XCTest.h>

#import "GSCXSwizzledMethodNotifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXSwizzledMethodNotifier (ExposedForTesting)

+ (void)_swizzleClass:(Class)classToSwizzle
             selector:(SEL)originalSelector
         withSelector:(SEL)newSelector;

@end

@interface GSCXSwizzledMethodNotifierTests : XCTestCase

/**
 * The number of times @c gscx_originalMethod has been invoked.
 */
@property(assign, nonatomic) NSInteger originalMethodCallCount;

/**
 * The number of times @c gscx_swizzledMethod has been invoked.
 */
@property(assign, nonatomic) NSInteger swizzledMethodCallCount;

@end

@implementation GSCXSwizzledMethodNotifierTests

- (void)setUp {
  [super setUp];
  self.originalMethodCallCount = 0;
  self.swizzledMethodCallCount = 0;
}

- (void)testOriginalImplementationsAreCalledBeforeSwizzling {
  XCTAssertEqual(self.originalMethodCallCount, 0);
  XCTAssertEqual(self.swizzledMethodCallCount, 0);
  [self gscxtest_originalMethod];
  XCTAssertEqual(self.originalMethodCallCount, 1);
  XCTAssertEqual(self.swizzledMethodCallCount, 0);
  [self gscxtest_swizzledMethod];
  XCTAssertEqual(self.originalMethodCallCount, 1);
  XCTAssertEqual(self.swizzledMethodCallCount, 1);
}

- (void)testSwizzledImplementationsAreCalledAfterSwizzling {
  XCTAssertEqual(self.originalMethodCallCount, 0);
  XCTAssertEqual(self.swizzledMethodCallCount, 0);
  [GSCXSwizzledMethodNotifier _swizzleClass:[GSCXSwizzledMethodNotifierTests class]
                                   selector:@selector(gscxtest_originalMethod)
                               withSelector:@selector(gscxtest_swizzledMethod)];
  [self gscxtest_originalMethod];
  XCTAssertEqual(self.originalMethodCallCount, 0);
  XCTAssertEqual(self.swizzledMethodCallCount, 1);
  [self gscxtest_swizzledMethod];
  XCTAssertEqual(self.originalMethodCallCount, 1);
  XCTAssertEqual(self.swizzledMethodCallCount, 1);
  // Return methods to original implementations so future tests are unaffected.
  [GSCXSwizzledMethodNotifier _swizzleClass:[GSCXSwizzledMethodNotifierTests class]
                                   selector:@selector(gscxtest_swizzledMethod)
                               withSelector:@selector(gscxtest_originalMethod)];
}

/**
 * Increments @c originalMethodCallCount.
 */
- (void)gscxtest_originalMethod {
  self.originalMethodCallCount++;
}

/**
 * Increments @c swizzledMethodCallCount.
 */
- (void)gscxtest_swizzledMethod {
  self.swizzledMethodCallCount++;
}

@end

NS_ASSUME_NONNULL_END
