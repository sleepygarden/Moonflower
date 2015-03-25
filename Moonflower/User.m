//
//  User.m
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "User.h"

@implementation User

-(id)init {
    self = [super init];
    if (self){
        NSLog(@"loading class defaults for instance of %@",[self class]);
    }
    return self;
}
+(NSDictionary*)jsonOverrideKeys {
    return @{@"name":@"username"};
}
+(NSArray*)ignoredProperties {
    return @[@"pantsSize"];
}
-(void)didGenerateFromJSON:(NSDictionary*)json {
    NSLog(@"user did generate, name:%@",self.name);
}

-(NSString*)stringRepresentationOfObject:(id)obj {
    NSLog(@"string rep of obj %@",obj);
    return [super stringRepresentationOfObject:obj];
}
-(id)objectFromStringRepresentation:(NSString *)stringRepresentation {
    NSLog(@"obj rep of string %@",stringRepresentation);
    return [super objectFromStringRepresentation:stringRepresentation];
}
@end
