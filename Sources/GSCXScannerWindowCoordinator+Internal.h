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

#import "GSCXScannerWindowCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Internal API only used by the scanner and its test app. Not for use by external clients.
 */
@interface GSCXScannerWindowCoordinator (Internal)

/**
 * Constructs a @c GSCXScannerWindowCoordinator instance presenting either one or many results
 * windows.
 *
 * @param isMultiWindowPresentation @c YES if the coordinator should allow multiple results windows,
 * @c NO otherwise.
 * @return A GSCXScannerWindowCoordinator instance.
 */
+ (instancetype)coordinatorWithMultiWindowPresentation:(BOOL)isMultiWindowPresentation;

@end

NS_ASSUME_NONNULL_END
