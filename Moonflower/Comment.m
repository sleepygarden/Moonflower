//
//  Comment.m
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "Comment.h"

@implementation Comment
+(NSDictionary*)jsonOverrideKeys {
    return @{@"commentID":@"comment_id"};
}
-(void)didGenerateFromJSON:(NSDictionary *)json {
    NSLog(@"did generate %lu,",self.commentID);
}

@end
