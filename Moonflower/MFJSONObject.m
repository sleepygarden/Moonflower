//
//  MFJSONObject.m
//  Moonflower
//
//  Created by Michael Cornell on 3/24/15.
//  Copyright (c) 2015 Sleepy. All rights reserved.
//

#import "MFJSONObject.h"
#import <objc/runtime.h>

@interface MFJSONObject ()
@end

@implementation MFJSONObject

NSString * const kMFJSONClassKey = @"_mf_class_key";

#pragma mark - Override These

+(NSDictionary*)jsonOverrideKeys {
    return @{};
}
+(NSArray*)ignoredProperties {
    return @[];
}

-(void)didGenerateFromJSON:(NSDictionary *)json {
}
-(NSDictionary*)amendOutgoingJSON:(NSDictionary *)outgoingJSON {
    return outgoingJSON;
}

-(id)objectFromStringRepresentation:(NSString *)stringRepresentation {
    return nil;
}
-(NSString*)stringRepresentationOfObject:(id)obj {
    return [obj description];
}

-(NSDateFormatter*)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

#pragma mark - Generate, Pack + unpack
+(instancetype)generate:(NSDictionary *)properties {
    Class klass = NSClassFromString([self _formatClassNameCamelCase:properties[kMFJSONClassKey]]);
    properties = [klass _formatJSONKeysCamelCase:properties]; // applies user defined clean up of under_score_syntax for camelCaseSyntax
    id instance = [[klass alloc] initWithJSON:properties];
    [instance didGenerateFromJSON:properties];
    return instance;
}

+(instancetype)generateFromString:(NSString *)jsonString {
    NSError *error;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *properties = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Error, couldn't parse JSON string %@",error.localizedDescription);
        return nil;
    }
    else {
        return [self generate:properties];
    }
}

-(id)initWithJSON:(NSDictionary *)json {
    self = [self init];
    if (self){
        for (NSString *propertyName in [self _propertyNames]){
            NSString *key = propertyName;
            if ([[self class] jsonOverrideKeys][propertyName]){
                key = [[self class] jsonOverrideKeys][propertyName];
            }
            id value = json[key];
            if (value){
                if ([value isKindOfClass:[NSDictionary class]]){
                    if ([(NSDictionary*)value count] == 0){
                        [self setValue:[NSNull null] forKey:propertyName];
                    }
                    else {
                        [self setValue:[self _recursiveGenerateDict:value] forKey:propertyName];
                    }
                }
                else if ([value isKindOfClass:[NSArray class]]){
                    if ([(NSArray*)value count] == 0){
                        [self setValue:[NSNull null] forKey:propertyName];
                    }
                    else {
                        [self setValue:[self _recursiveGenerateArray:value] forKey:propertyName];
                    }
                }
                else if ([value isKindOfClass:[NSNumber class]]){
                    [self setValue:value forKey:propertyName];
                }
                else if (![value isKindOfClass:[NSNull class]]){
                    value = [self _objectForString:value propertyName:propertyName];
                    [self setValue:value forKey:propertyName];
                }
            }
            else {
                NSLog(@"Error, value for key %@ not found",key);
            }
        }
    }
    return self;
}

// recursively packs an object and it's properties into a JSON ready dict
-(NSDictionary*)json {
    NSMutableDictionary *json = [NSMutableDictionary new];
    for (NSString *propertyName in [self _propertyNames]) {
        
        id value = [self valueForKey:propertyName];
        NSString *key = [[self class] _keyForPropertyName:propertyName];
        
        if (value == nil || [value isKindOfClass:[NSNull class]]){
            json[key] = [NSNull null];
        }
        else if ([value isKindOfClass:[MFJSONObject class]] && [value respondsToSelector:@selector(json)]){ // child is an instance of JSONObject
            json[key] = [value json];
        }
        else if ([value isKindOfClass:[NSArray class]]){
            if ([(NSArray*)value count] == 0){
                json[key] = [NSNull null];
            }
            else {
                NSMutableArray *mArr = [value mutableCopy];
                for (int idx = 0; idx < [value count]; idx++){
                    id collectionValue = [value objectAtIndex:idx];
                    if ([collectionValue isKindOfClass:[MFJSONObject class]] && [collectionValue respondsToSelector:@selector(json)]){
                        mArr[idx] = [collectionValue json];
                    }
                }
                json[key] = mArr;
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]]){
            if ([(NSDictionary*)value count] == 0){
                json[key] = [NSNull null];
            }
            else {
                NSMutableDictionary *mDict = [value mutableCopy];
                for (id key in [value keyEnumerator]){
                    id collectionValue = [value objectForKey:key];
                    if ([collectionValue isKindOfClass:[MFJSONObject class]] && [collectionValue respondsToSelector:@selector(json)]){
                        mDict[key] = [collectionValue json];
                    }
                }
                json[key] = mDict;
            }
        }
        else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]){
            json[key] = value;
        }
        else if ([value isKindOfClass:[NSValue class]]) {
            NSLog(@"Warning, can't pack and unpack structs, use a dict. returning nil");
            json[key] = [NSNull null];
        }
        else {
            json[key] = [self _stringForObject:value];
        }
    }
    json[kMFJSONClassKey] = NSStringFromClass([self class]);
    return [self amendOutgoingJSON:json];
}

-(NSString*)jsonString {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.json options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - Private Methods

+(NSString*)_keyForPropertyName:(NSString*)propertyName {
    if ([self jsonOverrideKeys][propertyName]){
        propertyName = [self jsonOverrideKeys][propertyName];
    }
    propertyName = [self _formatUnderScore:propertyName];
    return propertyName;
}

// recursively search through dictionary values for more MSJSONObjects
-(id)_recursiveGenerateDict:(NSDictionary*)dict{
    if (dict[kMFJSONClassKey]){ // found a dict which describes a sub obj
        Class klass = NSClassFromString([MFJSONObject _formatClassNameCamelCase:dict[kMFJSONClassKey]]);
        return [klass generate:dict];
    }
    else { // for each element, check for sub obj
        NSMutableDictionary *mDict = [dict mutableCopy];
        for (id key in [dict keyEnumerator]){
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                mDict[key] = [self _recursiveGenerateDict:dict[key]];
            }
            else if ([dict[key] isKindOfClass:[NSArray class]]){
                mDict[key] = [self _recursiveGenerateArray:dict[key]];
            }
        }
        return mDict;
    }
}

// recursively search through dictionary values for more MSJSONObjects
-(id)_recursiveGenerateArray:(NSArray*)array{
    NSMutableArray *mArr = [array mutableCopy];
    for (int idx = 0; idx < array.count; idx++){
        id value = array[idx];
        if ([value isKindOfClass:[NSArray class]]){
            mArr[idx] = [self _recursiveGenerateArray:value];
        }
        else if ([value isKindOfClass:[NSDictionary class]]){
            mArr[idx] = [self _recursiveGenerateDict:value];
        }
    }
    return mArr;
}

#pragma mark - parse json to and from objects

-(NSString*)_stringForObject:(id)obj {
    if ([obj isKindOfClass:[NSURL class]]){
        return [(NSURL*)obj absoluteString];
    }
    else if ([obj isKindOfClass:[NSDate class]]){
        return [self.dateFormatter stringFromDate:obj];
    }
    else {
        return [self stringRepresentationOfObject:obj];
    }
}

-(id)_objectForString:(id)string propertyName:(NSString*)propertyName{
    NSString *typeStr = [[self class] _typeOfPropertyNamed:propertyName];
    if ([typeStr containsString:@"NSString"]){
        return string;
    }
    else if ([typeStr containsString:@"NSURL"]){
        return [NSURL URLWithString:string];
    }
    else if ([typeStr containsString:@"NSDate"]){
        return [self.dateFormatter dateFromString:string];
    }
    else {
        id obj = [self objectFromStringRepresentation:string];
        if (obj == nil){
            NSLog(@"Warning, Unhandled object type %@, named %@",typeStr,propertyName);
        }
        return obj;
    }
}

+(NSString*)_typeOfPropertyNamed:(NSString *)name {
    NSString *propertyType = [self _propertyTypeCache][name];
    if (propertyType){
        return propertyType;
    }
    else {
        objc_property_t property = class_getProperty(self, [name UTF8String]);
        if (property == NULL) {
            return (NULL);
        }
        
        const char* attrs = property_getAttributes(property);
        if (attrs == NULL) {
            return (NULL);
        }
        
        static char buffer[256];
        const char *e = strchr(attrs, ',');
        if (e == NULL){
            return (NULL);
        }
        
        int len = (int)(e - attrs);
        memcpy(buffer, attrs, len);
        buffer[len] = '\0';
        propertyType = [NSString stringWithUTF8String:buffer];
        [self _propertyTypeCache][name] = propertyType;
        return propertyType;
    }
}

#pragma mark - format keys

+(NSDictionary*)_formatJSONKeysCamelCase:(NSDictionary*)rawJSON {
    NSMutableDictionary *json = [NSMutableDictionary new];
    for (NSString *key in [rawJSON keyEnumerator]) {
        if ([[[self jsonOverrideKeys] allValues] containsObject:key]){ // user manually specified a key, it'll be translated in unpacking
            json[key] = rawJSON[key];
        }
        else if ([key isEqualToString:kMFJSONClassKey]){
            json[key] = [self _formatClassNameCamelCase:rawJSON[key]];
        }
        else {
            json[[self _formatPropertyNameCamelCase:key]] = rawJSON[key];
        }
    }
    return json;
}

// default formatting for property names when reading keys
+(NSString*)_formatUnderScore:(NSString*)propertyName {
    NSString *jsonKey = [self _underscoreJSONKeyCache][propertyName];
    if (jsonKey){
        return jsonKey;
    }
    else {
        jsonKey = propertyName;
        NSString *searchPattern = @"([a-z][A-Z])";
        NSError *error;
        NSMutableSet *swaps = [NSMutableSet new];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchPattern options:0 error:&error];
        if (!error){
            [regex enumerateMatchesInString:jsonKey options:0 range:NSMakeRange(0, jsonKey.length) usingBlock:
             ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                 [swaps addObject:[jsonKey substringWithRange:result.range]];
             }];
            for (NSString *stringToSwap in swaps){
                NSString *formatted = [NSString stringWithFormat:@"%c_%c",[stringToSwap characterAtIndex:0],[stringToSwap characterAtIndex:1]];
                jsonKey = [jsonKey stringByReplacingOccurrencesOfString:stringToSwap withString:formatted];
            }
        }
        else {
            NSLog(@"Error, failed to format property name: %@",error.localizedDescription);
        }
        
        // catch word trailing ALLCAPS word
        searchPattern = @"([A-Z][a-z])";
        swaps = [NSMutableSet new];
        regex = [NSRegularExpression regularExpressionWithPattern:searchPattern options:0 error:&error];
        if (!error){
            [regex enumerateMatchesInString:jsonKey options:0 range:NSMakeRange(0, jsonKey.length) usingBlock:
             ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                 [swaps addObject:[jsonKey substringWithRange:result.range]];
             }];
            for (NSString *stringToSwap in swaps){
                NSString *formatted = [NSString stringWithFormat:@"_%@",stringToSwap];
                jsonKey = [jsonKey stringByReplacingOccurrencesOfString:stringToSwap withString:formatted];
            }
        }
        else {
            NSLog(@"Error, failed to format property name: %@",error.localizedDescription);
        }
        
        jsonKey = [jsonKey lowercaseString]; // catch ALLCAPS
        while ([jsonKey containsString:@"__"]) {
            jsonKey = [jsonKey stringByReplacingOccurrencesOfString:@"__" withString:@"_"]; // catch camel case which already had underscores
        }
        
        [self _underscoreJSONKeyCache][propertyName] = jsonKey;
        return propertyName;
    }
}

// default formatting for property names when reading keys
+(NSString*)_formatPropertyNameCamelCase:(NSString*)jsonKey {
    NSString *camelCasePropertyName = [self _camelCaseNameCache][jsonKey];
    if (camelCasePropertyName){
        return camelCasePropertyName;
    }
    else {
        camelCasePropertyName = jsonKey;
        NSString *searchPattern = @"_."; //
        NSError *error;
        NSMutableSet *swaps = [NSMutableSet new];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchPattern options:0 error:&error];
        if (!error){
            [regex enumerateMatchesInString:camelCasePropertyName options:0 range:NSMakeRange(0, camelCasePropertyName.length) usingBlock:
             ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                 [swaps addObject:[camelCasePropertyName substringWithRange:result.range]];
             }];
            for (NSString *stringToSwap in swaps){
                NSString *formatted = [[NSString stringWithFormat:@"%c",[stringToSwap characterAtIndex:1]] uppercaseString];
                camelCasePropertyName = [camelCasePropertyName stringByReplacingOccurrencesOfString:stringToSwap withString:formatted];
            }
        }
        else {
            NSLog(@"Error, failed to format property name: %@",error.localizedDescription);
        }
        
        [self _camelCaseNameCache][jsonKey] = camelCasePropertyName;
        return camelCasePropertyName;
    }
}

// default formatting for class names
+(NSString*)_formatClassNameCamelCase:(NSString*)className {
    NSString *camelCaseClassName = [self _camelCaseNameCache][className];
    if (camelCaseClassName){
        return camelCaseClassName;
    }
    else {
        camelCaseClassName = [self _formatPropertyNameCamelCase:className];
        NSString *firstChar = [[NSString stringWithFormat:@"%c",[camelCaseClassName characterAtIndex:0]] uppercaseString];
        camelCaseClassName = [NSString stringWithFormat:@"%@%@",firstChar,[camelCaseClassName substringFromIndex:1]];
        [self _camelCaseNameCache][className] = camelCaseClassName;
        return camelCaseClassName;
    }
}

#pragma mark - property names

-(NSArray*)_propertyNames {
    return [MFJSONObject _propertiesForHierarchyOfClass:[self class]];
}

+(NSArray*)_propertiesForHierarchyOfClass:(Class)klass {
    if (klass == [NSObject class]) { // base case, we can skip these
        return nil;
    }
    
    // Collect properties from the current class, append the subclasses properties
    NSArray *props = [self _propertiesForSubclass:klass];
    return [props arrayByAddingObjectsFromArray:[self _propertiesForHierarchyOfClass:[klass superclass]]];
    
}

+(BOOL)_propertyShouldBeSkipped:(NSString*)name {
    return (![name isEqualToString:@"description"] && // properties set by NSObject, dont sweat this
            ![name isEqualToString:@"debugDescription"] &&
            ![name isEqualToString:@"superclass"] &&
            ![name isEqualToString:@"hash"] &&
            ![[self ignoredProperties] containsObject:name]);
}

+(NSArray*)_propertiesForSubclass:(Class)klass {
    NSString *className = NSStringFromClass(klass);
    NSArray *classProperties = [self _classPropertiesCache][className];
    if (classProperties){
        return classProperties;
    }
    else {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(klass, &count);
        NSMutableArray *propertyList = [NSMutableArray new];
        for (unsigned idx = 0; idx < count; idx++) {
            objc_property_t property = properties[idx];
            NSString *name = [NSString stringWithUTF8String:property_getName(property)];
            if ([klass _propertyShouldBeSkipped:name]){
                [propertyList addObject:name];
            }
        }
        free(properties);
        classProperties = [NSArray arrayWithArray:propertyList];
        [self _classPropertiesCache][className] = classProperties;
        return classProperties;
    }
}

#pragma mark - caching

+(NSMutableDictionary*)_camelCaseNameCache {
    static NSMutableDictionary *camelCaseJSONKeysCache;
    static dispatch_once_t _camelCaseJSONKeyCacheToken;
    dispatch_once(&_camelCaseJSONKeyCacheToken, ^{
        camelCaseJSONKeysCache = [NSMutableDictionary new];
    });
    return camelCaseJSONKeysCache;
}

+(NSMutableDictionary*)_underscoreJSONKeyCache {
    static NSMutableDictionary *underscorePropNamesCache;
    static dispatch_once_t _underscorePropNamesCacheToken;
    dispatch_once(&_underscorePropNamesCacheToken, ^{
        underscorePropNamesCache = [NSMutableDictionary new];
    });
    return underscorePropNamesCache;
}

+(NSMutableDictionary*)_classPropertiesCache {
    static NSMutableDictionary *classPropertiesCache;
    static dispatch_once_t _classPropertiesCacheToken;
    dispatch_once(&_classPropertiesCacheToken, ^{
        classPropertiesCache = [NSMutableDictionary new];
    });
    return classPropertiesCache;
}

+(NSMutableDictionary*)_propertyTypeCache {
    static NSMutableDictionary *propertyTypeCache;
    static dispatch_once_t _propertyTypeCache;
    dispatch_once(&_propertyTypeCache, ^{
        propertyTypeCache = [NSMutableDictionary new];
    });
    return propertyTypeCache;
}

@end
