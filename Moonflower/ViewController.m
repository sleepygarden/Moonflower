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
    __block User *user;
    [self timeBlock:^{
        user = [[User alloc] initWithName:@"Mike"];
        user.bff = [[User alloc] initWithName:@"Erin"];
    } times:1000];
    
    [self timeBlock:^{
        NSDictionary *json = user.json;
        [User generate:json];
    } times:1000];
        
    [self timeBlock:^{
        NSDictionary *json = user.json;
        [User generate:json];
    } times:1000];
    
    [self timeBlock:^{
        NSDictionary *json = user.json;
        [User generate:json];
    } times:1000];
}

-(void)timeBlock:(void (^)(void))block times:(int)testTimes{
    NSDate *methodStart = [NSDate date];
    for (int idx = 0; idx < testTimes; idx++) {
        block();
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart] / testTimes;
    NSLog(@"executionTime = %f", executionTime);
}

@end
