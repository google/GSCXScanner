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

#import <GTXiLib/GTXiLib.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The name of the check that fails elements with tag @c kGSCXTestCheckFailingElementTag.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestCheckName;

/**
 * The description of the check that fails elements with tag @c kGSCXTestCheckFailingElementTag.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestCheckDescription;

/**
 * The tag for which instances of @c GSCXTestCheck fail views.
 */
FOUNDATION_EXTERN const NSInteger kGSCXTestCheckFailingElementTag;

/**
 * A dummy @c GTXChecking instance that fails views with tag @c kGSCXTestCheckFailingElementTag.
 */
@interface GSCXTestCheck : NSObject <GTXChecking>

/**
 * @return A @c GSCXTestCheck instance.
 */
+ (instancetype)testCheck;

/**
 * @return A @c GSCXTestCheck instance failing the same elements as @c testCheck but with a
 * different value for @c name. This lets the same check count multiple times to simulate multiple
 * issues with the same UI element.
 */
+ (instancetype)duplicateTestCheck;

@end

NS_ASSUME_NONNULL_END
