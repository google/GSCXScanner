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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The minimum dimensions of a UI element to satisfy touch target guidelines.
 */
FOUNDATION_EXTERN const CGFloat kGSCXMinimumTouchTargetSize;

/**
 * Contains common utility methods for GSCXScanner.
 */
@interface GSCXUtils: NSObject

/**
 * Do not create an instance of this class.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates a globally unique directory in this device's temporary directory.
 * Crashes with an assertion if the directory could not be created.
 *
 * @return The URL of the created directory.
 */
+ (NSURL *)uniqueTemporaryDirectoryURL;

@end

NS_ASSUME_NONNULL_END
