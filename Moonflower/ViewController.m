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
    User *user = [[User alloc] initWithName:@"Mike"];
    user.bff = [[User alloc] initWithName:@"Erin"];
    NSLog(@"User: %@",user.json);
    NSDictionary *json = user.json;
    User *cloneUser = [User generate:json];
    NSLog(@"Clone: %@",cloneUser.json);
}

@end
