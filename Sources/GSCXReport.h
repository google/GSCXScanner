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

#import <Foundation/Foundation.h>

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Block type definition for indicating report generation completion.
 */
typedef void(^GSCXReportCompletionBlock)(NSURL *reportUrl);

/**
 *  Class responsible for generating reports and showing UI for sharing it.
 */
@interface GSCXReport : NSObject

/**
 *  Creates a report from the given  result object and shows a share sheet for it.
 *
 *  @param result The result objecct to be shown on the report.
 *  @param onComplete Completion handler to be invoked.
 */
- (void)beginSharingResult:(GSCXScannerResult *)result
       withCompletionBlock:(GSCXReportCompletionBlock)onComplete;

@end

NS_ASSUME_NONNULL_END
