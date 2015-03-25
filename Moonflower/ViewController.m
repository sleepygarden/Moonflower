//
//  ViewController.m
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "Post.h"
#import "Comment.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    User *user = [[User alloc] init];
    user.name = @"Mike";
    user.pantsSize = CGSizeMake(36, 30);
    user.userNumber = 0;
    
    User *otherUser = [[User alloc] init];
    otherUser.name = @"Erin";
    otherUser.userNumber = 1;
    
    Comment *commentA = [[Comment alloc] init];
    commentA.commentID = 0;
    commentA.creationDate = [NSDate date];
    
    Comment *commentB = [[Comment alloc] init];
    commentB.commentID = 1;
    commentB.creationDate = [[NSDate date] dateByAddingTimeInterval:500];
    
    Post *post = [[Post alloc] init];
    post.creationDate = [[NSDate date] dateByAddingTimeInterval:-500];
    post.comments = @[commentA,commentB];
    post.shareURL = [NSURL URLWithString:@"http://www.example.com"];
    
    user.postDict = [@{@"post":post,
                      @"string":@"lmao"} mutableCopy];
    
    user.bff = otherUser;
    
    NSDictionary *json = user.json;
    NSLog(@"JSON %@",json);
    NSLog(@"JSON STRING %@",user.jsonString);

    User *user2 = [User generate:json];
    NSLog(@"JSON 2 %@", user2.json);
    NSLog(@"JSON 2 STRING %@",user.jsonString);
    
}

@end
