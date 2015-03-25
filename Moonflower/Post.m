//
//  Post.m
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "Post.h"

@implementation Post
+(NSDictionary*)jsonOverrideKeys {
    return @{@"shareURL":@"share_url"};
}
@end
