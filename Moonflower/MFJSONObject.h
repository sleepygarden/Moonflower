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

+(instancetype)generate:(NSDictionary*)properties;
+(instancetype)generateFromString:(NSString*)jsonString;

+(NSDictionary*)jsonOverrideKeys; // override to manually define what json keys go to what property names
+(NSArray*)ignoredProperties; // these properties won't be packed/unpacked. matches local property names, not json keys

// override these to manually handle how a class packs and unpacks objects of a certain type. MFJSONObject does NSURLs and NSDates for you
-(id)objectFromStringRepresentation:(NSString*)stringRepresentation;
-(NSString*)stringRepresentationOfObject:(id)obj;

-(id)initWithProperties:(NSDictionary*)properties;
-(void)didGenerateFromJSON:(NSDictionary*)json; // do additional setup while unpacking from json
-(NSDictionary*)amendOutgoingJSON:(NSDictionary*)outgoingJSON; // do additional setup while packing object into json
-(NSDictionary*)json;
-(NSDictionary*)jsonString;
@end
