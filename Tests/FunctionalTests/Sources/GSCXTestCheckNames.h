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

#import <Foundation/Foundation.h>

/**
 * The name of the first installed check which fails elements for a given tag.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestCheckName1;

/**
 * The tag for which the first installed check fails elements.
 */
FOUNDATION_EXTERN const NSInteger kGSCXTestCheckTag1;

/**
 * The name of the second installed check which fails elements for a given tag.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestCheckName2;

/**
 * The tag for which the second installed check fails elements.
 */
FOUNDATION_EXTERN const NSInteger kGSCXTestCheckTag2;

/**
 * The name of the third installed check which fails elements for a given tag.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestCheckName3;

/**
 * The tag for which the third installed check fails elements.
 */
FOUNDATION_EXTERN const NSInteger kGSCXTestCheckTag3;

/**
 * The name of the fourth installed check which fails elements for a given tag. Fails the same
 * elements as the first installed check.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestCheckName4;

/**
 * The tag for which the fourth installed check fails elements. Equal to kGSCXTagCheckTag1.
 */
FOUNDATION_EXTERN const NSInteger kGSCXTestCheckTag4;

/**
 * The name of the fifth installed check which fails elements for a given tag. The description
 * of this check contains non-ASCII UTF8 characters.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestUTF8CheckName5;

/**
 * The tag for which the fifth installed check fails elements.
 */
FOUNDATION_EXTERN const NSInteger kGSCXTestUTF8CheckTag5;
