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
@property (strong, nonatomic) NSMutableDictionary *postDict;
@property (nonatomic) CGSize pantsSize;
@property (strong, nonatomic) User *bff;
@property (nonatomic) NSUInteger userNumber;
@end
