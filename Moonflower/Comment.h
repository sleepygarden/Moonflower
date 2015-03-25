//
//  Comment.h
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "MFJSONObject.h"
#import "User.h"
@interface Comment : MFJSONObject
@property (strong, nonatomic) NSDate *creationDate;
@property (nonatomic) NSUInteger commentID;
@end
