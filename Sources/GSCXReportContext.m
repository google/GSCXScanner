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

#import "GSCXReportContext.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXReportContext {
  NSInteger _imageIndex;
  NSMutableDictionary *_imageFromPathPlaceholder;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _imageFromPathPlaceholder = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (NSString *)pathByAddingImage:(UIImage *)image {
  NSString *pathPlaceholder = [self gscx_nextImagePathPlaceholder];
  _imageFromPathPlaceholder[pathPlaceholder] = image;
  return pathPlaceholder;
}

- (void)forEachImageWithHandler:(GSCXReportContextForEachImageHandler)handler {
  for (NSString *path in _imageFromPathPlaceholder) {
    handler(_imageFromPathPlaceholder[path], path);
  }
}

#pragma mark - Private

/**
 * @return The next image path placeholder.
 */
- (NSString *)gscx_nextImagePathPlaceholder {
  _imageIndex += 1;
  return [NSString stringWithFormat:@"image_%d.png", (int)_imageIndex];
}

@end

NS_ASSUME_NONNULL_END
