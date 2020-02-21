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

#import "GSCXScannerSettingsBlockItem.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerSettingsBlockItem ()

@property(copy, nonatomic) void (^configure)(GSCXScannerSettingsTableViewCell *);

@end

@implementation GSCXScannerSettingsBlockItem

- (instancetype)initWithBlock:(void (^)(GSCXScannerSettingsTableViewCell *))block {
  self = [super init];
  if (self) {
    _configure = block;
  }
  return self;
}

+ (instancetype)itemWithBlock:(void (^)(GSCXScannerSettingsTableViewCell *))block {
  return [[GSCXScannerSettingsBlockItem alloc] initWithBlock:block];
}

- (void)configureTableViewCell:(nonnull GSCXScannerSettingsTableViewCell *)tableViewCell {
  GTX_ASSERT(self.configure, @"block must be nonnull.");
  self.configure(tableViewCell);
}

@end

NS_ASSUME_NONNULL_END
