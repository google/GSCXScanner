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

#import "GSCXUtils.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@implementation GSCXUtils

+ (NSURL *)uniqueTemporaryDirectoryURL {
  NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
  NSString *tempDirName = [[NSProcessInfo processInfo] globallyUniqueString];
  temporaryDirectoryURL = [temporaryDirectoryURL URLByAppendingPathComponent:tempDirName];
  NSError *error;
  [[NSFileManager defaultManager] createDirectoryAtURL:temporaryDirectoryURL
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:&error];
  GTX_ASSERT(error == nil, @"Could not create sharable dir: %@", error);
  return temporaryDirectoryURL;
}

@end

NS_ASSUME_NONNULL_END
