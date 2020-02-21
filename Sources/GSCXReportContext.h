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
 * A handler type for for-each method that provides image and its associated filename.
 */
typedef void(^GSCXReportContextForEachImageHandler)(UIImage *image, NSString *filename);

/**
 * Contextual information about current report, allows for adding images to the report.
 */
@interface GSCXReportContext : NSObject

/**
 * Adds an image to the report and returns an appropriate path for it.
 *
 * @param image Image to be added.
 *
 * @return A relative path to be used for saving the image.
 */
- (NSString *)pathByAddingImage:(UIImage *)image;

/**
 * Iterates through all the images in the context.
 *
 * @param handler The handler to be invoked on each of the images.
 */
- (void)forEachImageWithHandler:(GSCXReportContextForEachImageHandler)handler;

@end

NS_ASSUME_NONNULL_END
