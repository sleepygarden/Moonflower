# Moonflower
Generate Objective-C models from JSON and generate JSON from those Models. Built in support for: 
* ```NSString```
* ```NSArray```
* ```NSDictionary```
* ```NSNumber```
* ```NSDate```
* ```NSURL```
* Null values with ```NSNull```
* All primitive data types (```int```, ```BOOL```, ```float```, ```CGFloat```, etc)

__It's really simple!__

```objc
// User.h
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

// User.m
@implementation User
-(id)initWithName:(NSString*)name{
    self = [self init];
    if (self) {
        self.name = name;
        self.dict = [NSDictionary new]; // empty
        self.userId = [name hash];
        self.joinDate = [NSDate date];
        self.array = nil;
        self.profilePicUrl = [NSURL URLWithString:@"http://www.example.com"];
    }
    return self;
}
@end

// ViewController.m (usage example)
...
User *user = [[User alloc] initWithName:@"Mike"];
user.bff = [[User alloc] initWithName:@"Erin"];
NSLog(@"User: %@",user.json);

NSDictionary *json = user.json
User *cloneUser = [User generate:json];
NSLog(@"Clone: %@",cloneUser.json);

...
```
Output:

```
2015-03-25 15:49:10.357 Moonflower[36383:590551] User: {
    "_mf_class_key" = User;
    array = "<null>";
    bff =     {
        "_mf_class_key" = User;
        array = "<null>";
        bff = "<null>";
        dict = "<null>";
        "join_date" = "2015-03-25T15:49:10Z";
        "profile_pic_url" = "http://www.example.com";
        "user_id" = 24629872306;
        username = Erin;
    };
    dict = "<null>";
    "join_date" = "2015-03-25T15:49:10Z";
    "profile_pic_url" = "http://www.example.com";
    "user_id" = 26928320042;
    username = Mike;
}
2015-03-25 15:49:10.363 Moonflower[36383:590551] Clone: {
    "_mf_class_key" = User;
    array = "<null>";
    bff =     {
        "_mf_class_key" = User;
        array = "<null>";
        bff = "<null>";
        dict = "<null>";
        "join_date" = "2015-03-25T15:49:10Z";
        "profile_pic_url" = "http://www.example.com";
        "user_id" = 24629872306;
        username = Erin;
    };
    dict = "<null>";
    "join_date" = "2015-03-25T15:49:10Z";
    "profile_pic_url" = "http://www.example.com";
    "user_id" = 26928320042;
    username = Mike;
}
```

That's it! Every class which is a subclass of MFJSONObject can be neatly imported and exported with JSON, filling a classes properties based on the JSON keys.

Generation is straight forward:
```objc
// returns an instance of a model defined by the JSON. 
// It's helpful but not nessecary to know the class ahead of time.
+(instancetype)generate:(NSDictionary*)properties; 

// converts jsonString into a dict, returns generate:
+(instancetype)generateFromString:(NSString*)jsonString; 
```

Exporting is as straight forward:
```objc
// returns this instance as a JSON ready dict
-(NSDictionary*)json;

// returns self.json, and then writes it as a JSON string
-(NSString*)jsonString;
```

MFJSONObject also provides hooks to extend control of packing and unpacking JSON to the class. Override these methods in any subclass.
```objc
// do additional setup while unpacking from json
-(void)didGenerateFromJSON:(NSDictionary*)json; 

// do additional setup while packing object into json
-(NSDictionary*)amendOutgoingJSON:(NSDictionary*)outgoingJSON; 

// provide support for packing objects which aren't JSON ready
-(NSString*)stringRepresentationOfObject:(id)obj;

// provide support for unpacking objects which aren't JSON ready
-(id)objectFromStringRepresentation:(NSString*)stringRepresentation;

// user specified date formatter. 
// If not overrideen, defaults to locale = "en_US_POSIX", format = "yyyy-MM-dd'T'HH:mm:ss'Z'"
-(NSDateFormatter*)dateFormatter; 
```

MFJSONObject will automatically parse ```json_key_style``` into ```camelCaseStyle```, but provides support for user defined JSON key - property name relationships. Override these methods in any subclass.
```objc
// override to manually define what json keys go to what property names
+(NSDictionary*)jsonOverrideKeys; 

example ...
+(NSDictionary*)jsonOverrideKeys {
    return @{@"propertyName":@"json_key_name",
             @"name"        :@"username",
             @"commentID"   :@"comment_id"}; 
}
...

// properties with with these names will be outright ignored by MFJSONObject's packing and unpacking process
+(NSArray*)ignoredProperties; 

example ...
+(NSArray*)ignoredProperties {
    return @[@"anImage",
             @"aStruct",
             @"authToken"];
}
...
```
MFJSONObject will respect a class's basic init method, so overriding that in a subclass can help for setting non-null default values. MFJSONObject generation and json creation is recursive, so watch out for circular ownership chains. 
