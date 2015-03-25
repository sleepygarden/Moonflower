//
//  User.h
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "MFJSONObject.h"
#import <UIKit/UIKit.h>

@interface User : MFJSONObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSDate *joinDate;
@property (strong, nonatomic) NSURL *profilePicUrl;
@property (strong, nonatomic) User *bff;
@property (nonatomic) NSUInteger userId;
-(id)initWithName:(NSString*)name;
@end
