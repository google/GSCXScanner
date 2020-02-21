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

#import "GSCXInstallerOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains methods only for use by this library.
 */
@interface GSCXInstallerOptions (Internal)

/**
 * @return @c YES if the scanner settings button should remain over the results screen, @c NO
 * otherwise.
 */
- (BOOL)isMultiWindowPresentation;

/**
 * Sets the value of the multiple results windows option.
 *
 * @param isMultiWindowPresentation The new value of the multiple results window option.
 */
- (void)setMultiWindowPresentation:(BOOL)isMultiWindowPresentation;

@end

NS_ASSUME_NONNULL_END
