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

#import "GSCXTestCheck.h"

#import "GSCXScanner.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXTestCheck ()

/**
 * Creates a GTXChecking instance with the given name that fails UI elements with the given tag.
 *
 * @c name The name of the GTXChecking instance.
 * @c tag The tag which causes elements to fail the check.
 * @c descriptionFormat A string used to format the description. There must be exactly
 * two placeholders in descriptionFormat. The first placeholder must be %@ and the second must be
 * %ld.
 * @return A GTXChecking instance that fails elements with the given tag.
 */
+ (id<GTXChecking>)checkWithName:(NSString *)name
                             tag:(NSInteger)tag
               descriptionFormat:(NSString *)descriptionFormat;

@end

@implementation GSCXTestCheck : NSObject

+ (id<GTXChecking>)checkWithName:(NSString *)name tag:(NSInteger)tag {
  return [GSCXTestCheck checkWithName:name tag:tag descriptionFormat:@"%@ failed with tag %ld."];
}

+ (id<GTXChecking>)UTF8CheckWithName:(NSString *)name tag:(NSInteger)tag {
  return
      [GSCXTestCheck checkWithName:name
                               tag:tag
                 descriptionFormat:
                     @"%@ failed with tag %ld. This description contains "
                     @"non-ASCII characters such as ’, ™, ☠️, ⚠️, ◌̏, and e\u0300."];
}

+ (id<GTXChecking>)checkWithName:(NSString *)name
                             tag:(NSInteger)tag
               descriptionFormat:(NSString *)descriptionFormat {
  return [GTXCheckBlock
      GTXCheckWithName:name
                 block:^BOOL(id element, GTXErrorRefType errorOrNil) {
                   if ([element respondsToSelector:@selector(tag)] && [element tag] == tag) {
                     NSString *description =
                         [NSString stringWithFormat:descriptionFormat, name, (long)tag];
                     [NSError gtx_logOrSetGTXCheckFailedError:errorOrNil
                                                      element:element
                                                         name:name
                                                  description:description];
                     return NO;
                   } else {
                     return YES;
                   }
                 }];
}

@end

NS_ASSUME_NONNULL_END
