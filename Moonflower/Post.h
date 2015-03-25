//
//  Post.h
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "MFJSONObject.h"

@interface Post : MFJSONObject
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSURL *shareURL;
@property (strong, nonatomic) NSDate *creationDate;
@end
