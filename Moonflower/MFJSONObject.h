//
//  MFJSONObject.h
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFJSONObject : NSObject

// Objects should not own other objects which live above them in the hierarchy - they may own an object id to reference them however
// if you do this you'll end up with really bulky initialization calls, and possibly circular ownership cycles.

// returns an instance of a model defined by the JSON.
// It's helpful but not nessecary to know the class ahead of time.
+(instancetype)generate:(NSDictionary*)properties;

// converts jsonString into a dict, returns generate:
+(instancetype)generateFromString:(NSString*)jsonString;

// returns this instance as a JSON ready dict
-(NSDictionary*)json;

// returns self.json, and then writes it as a JSON string
-(NSString*)jsonString;

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

// override to manually define what json keys go to what property names
+(NSDictionary*)jsonOverrideKeys;

// properties with with these names will be outright ignored by MFJSONObject's packing and unpacking process
+(NSArray*)ignoredProperties;

@end
