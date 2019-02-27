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

#import "GSCXTestTagCheck.h"

#import "GSCXScanner.h"

@implementation GSCXTestTagCheck : NSObject

+ (id<GTXChecking>)checkWithName:(NSString *)name tag:(NSInteger)tag {
  return [GTXCheckBlock
      GTXCheckWithName:name
                 block:^BOOL(id _Nonnull element, GTXErrorRefType errorOrNil) {
                   if ([element respondsToSelector:@selector(tag)] && [element tag] == tag) {
                     NSString *description =
                         [NSString stringWithFormat:@"%@ failed with tag %ld.", name, (long)tag];
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
