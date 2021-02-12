//
// Copyright 2020 Google Inc.
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

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/ContinuousScannerTests/GSCXContinuousScannerTestCase.h"

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXTestEnvironmentVariables.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

@interface GSCXContinuousScannerTestCase ()

/**
 * The application driving the tests.
 */
@property(strong, nonatomic) XCUIApplication *application;

@end

@implementation GSCXContinuousScannerTestCase

- (void)setUp {
  [super setUp];

  [[GREYConfiguration sharedConfiguration] setValue:@[ kGSCXDoNotBlockNetworkRegex ]
                                       forConfigKey:kGREYConfigKeyBlockedURLRegex];
  // Launch a new application for each test case because the continuous scanner has global state.
  // Scans from previous test cases would propagate to later test cases unless a new application is
  // launched for each test case.
  self.application = [[XCUIApplication alloc] init];
  self.application.launchEnvironment = @{kEnvUseTestSharingDelegateKey : @"YES"};
  [self.application launch];
}

- (void)tearDown {
  if ([self shouldTerminateOnTeardown]) {
    [self.application terminate];
  }
  [super tearDown];
}

- (BOOL)shouldTerminateOnTeardown {
  return NO;
}

@end
