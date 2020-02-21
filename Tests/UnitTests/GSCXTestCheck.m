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

#import "GSCXTestCheck.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXTestCheckName = @"kGSCXTestCheckName";

NSString *const kGSCXTestCheckDescription = @"Dummy check failed.";

const NSInteger kGSCXTestCheckFailingElementTag = 127;

@interface GSCXTestCheck ()

/**
 * The name of this check.
 */
@property(strong, nonatomic) NSString *name;

/**
 * The block check used to perform the check on a view.
 */
@property(strong, nonatomic) id<GTXChecking> blockCheck;

@end

@implementation GSCXTestCheck

- (instancetype)init {
  self = [super init];
  if (self) {
    _name = kGSCXTestCheckName;
    __weak __typeof__(self) weakSelf = self;
    _blockCheck = [GTXCheckBlock
        GTXCheckWithName:kGSCXTestCheckName
                   block:^(id element, GTXErrorRefType errorOrNil) {
                     if ([element tag] == kGSCXTestCheckFailingElementTag) {
                       [NSError gtx_logOrSetGTXCheckFailedError:errorOrNil
                                                        element:element
                                                           name:weakSelf.name ?: kGSCXTestCheckName
                                                    description:kGSCXTestCheckDescription];
                       return NO;
                     } else {
                       return YES;
                     }
                   }];
  }
  return self;
}

+ (instancetype)testCheck {
  return [[GSCXTestCheck alloc] init];
}

+ (instancetype)duplicateTestCheck {
  GSCXTestCheck *check = [[GSCXTestCheck alloc] init];
  check.name = [check.name stringByAppendingString:@"2"];
  return check;
}

- (BOOL)check:(id)element error:(GTXErrorRefType)errorOrNil {
  return [self.blockCheck check:element error:errorOrNil];
}

@end

NS_ASSUME_NONNULL_END
