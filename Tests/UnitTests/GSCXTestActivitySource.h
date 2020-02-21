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

#import "GSCXActivitySourceMonitoring.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A stubbed implementation of @c GSCXActivitySourceMonitoring. Users can directly set the state of
 * the source, which propogates to the @c onStateChanged callback.
 */
@interface GSCXTestActivitySource : NSObject <GSCXActivitySourceMonitoring>

/**
 * @return A @c GSCXTestActivitySource instance.
 */
+ (instancetype)testSource;

/**
 * The state of this source. Setting this value invokes @c onStateChanged if it exists.
 */
@property(assign, nonatomic) GSCXActivityStateType state;

/**
 * The callback performed when this source's state changes.
 */
@property(copy, nonatomic, nullable) GSCXActivitySourceStateChangedBlock onStateChanged;

@end

NS_ASSUME_NONNULL_END
