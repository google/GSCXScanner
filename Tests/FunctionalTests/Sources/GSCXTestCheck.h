//
// Copyright 2018 Google Inc.
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

#import <Foundation/Foundation.h>

#import "GSCXScanner.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains factory methods for creating test GTXChecking instances. Instead of needing to
 * construct a specific view hierarchy or having to update the tests if the functionality of
 * GTXiLib checks change, tests can depend on these specific, enabling them to be more focused.
 */
@interface GSCXTestCheck : NSObject

/**
 * Creates a GTXChecking instance with the given name that fails UI elements with the given tag.
 *
 * @c name The name of the GTXChecking instance.
 * @c tag The tag which causes elements to fail the check.
 * @return A GTXChecking instance that fails elements with the given tag.
 */
+ (id<GTXChecking>)checkWithName:(NSString *)name tag:(NSInteger)tag;

/**
 * Creates a GTXChecking instance with the given name that fails UI elements with the given tag.
 * The description contains non-ASCII characters.
 *
 * @c name The name of the GTXChecking instance.
 * @c tag The tag which causes elements to fail the check.
 * @return A GTXChecking instance that fails elements with the given tag.
 */
+ (id<GTXChecking>)UTF8CheckWithName:(NSString *)name tag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
