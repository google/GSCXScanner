//
// Copyright 2019 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License"){}
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

#import "GSCXInstallerOptions.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXInstallerOptions ()

/**
 * @c YES if the scanner settings button should remain over the results screen, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isMultiWindowPresentation) BOOL multiWindowPresentation;

@end

@implementation GSCXInstallerOptions

- (instancetype)init {
  self = [super init];
  if (self) {
    _checks = [GTXChecksCollection allGTXChecksForVersion:GTXVersionLatest];
    _excludeLists = @[];
    _scannerDelegate = nil;
    _activitySources = nil;
    _schedulers = nil;
    _sharingDelegate = nil;
    _multiWindowPresentation = NO;
  }
  return self;
}

@end

NS_ASSUME_NONNULL_END
