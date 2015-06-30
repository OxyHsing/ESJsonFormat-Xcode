//
//  ESJsonFormatManager.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESJsonFormatManager.h"
#import "ESClassInfo.h"
#import "ESFormatInfo.h"
#import "ESClassInfo.h"

@interface ESJsonFormatManager()
@property (nonatomic, strong) NSMutableArray *classArray;
@property (nonatomic, strong) ESFormatInfo *formatInfo;
@end
@implementation ESJsonFormatManager
-(NSMutableArray *)classArray{
    if (!_classArray) {
        _classArray = [NSMutableArray array];
    }
    return _classArray;
}

- (instancetype)initWithCreateToFile:(BOOL)createToFile{
    self = [super init];
    if (self) {
        self.formatInfo = [[ESFormatInfo alloc] init];
        self.createNewFile = createToFile;
    }
    return self;
}

- (instancetype)init{
    return [self initWithCreateToFile:NO];
}

- (ESFormatInfo *)parseWithDic:(NSDictionary *)dic{
    /**
     *  Setting Default Config
     */
    _formatNumberType = ESFormatNumber_BoxType;
    _memMgnType = ESFormatMemMgntType_Copy;
    
    NSMutableString *resultStr = [NSMutableString string];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        [resultStr appendFormat:@"\n%@\n",[self formatWithKey:key value:obj]];
    }];
    if (!self.isCreateNewFile) {
        for (ESClassInfo *info in self.classArray) {
            [resultStr appendString:[NSString stringWithFormat:@"\n@end\n\n%@",[self parseClassWithClassInfo:info]]];
        }
    }
    self.formatInfo.pasteboardContent = resultStr;
    return self.formatInfo;
}
#pragma mark 
#pragma Magic Pieces
- (NSString *)convertNormalStringToCamelString:(NSString *)toBeConvertedString
{
    NSMutableString * convertedString = [toBeConvertedString mutableCopy];
    [toBeConvertedString enumerateSubstringsInRange:NSMakeRange(0, [toBeConvertedString length])
                                       options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                        [convertedString replaceCharactersInRange:substringRange
                                                                      withString:[substring capitalizedStringWithLocale:[NSLocale currentLocale]]];
                                        *stop = YES;
                                    }];
    return [convertedString copy];
}


#pragma mark -
#pragma mark DisPlay Magics
-(NSString *)displayRootStringWithKeyStr:(NSString *)keyString
{
    NSString * qualifierStr;
    NSString * typeStr = @"NSString";
    switch (_memMgnType) {

        case ESFormatMemMgntType_StrongRef:
            qualifierStr = @"strong";
            break;
        case ESFormatMemMgntType_WeakRef:
            qualifierStr = @"weak";
            break;
        case ESFormatMemMgntType_Copy:
        default:
            qualifierStr = @"copy";
            break;
    }
    
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,keyString];
}
- (NSString *)displayRootStringWithNumberType:(NSString *)valueString
{
    NSString * qualifierStr;
    NSString * typeStr;
    switch (_formatNumberType) {
        case ESFormatNumber_BoxType:
            typeStr = @"NSNumber";
            qualifierStr = @"copy";
            return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,valueString];
            break;
        case ESFormatNumber_DirectType:
        default:
            qualifierStr = @"assign";
            NSString *valueStr = [NSString stringWithFormat:@"%@",valueString];
            if ([valueStr rangeOfString:@"."].location!=NSNotFound){
                typeStr = @"CGFloat";
            }else{
                NSNumber *valueNumber = (NSNumber *)valueString;
                if ([valueNumber longValue]<2147483648) {
                    typeStr = @"NSInteger";
                }else{
                    typeStr = @"long long";
                }
            }
             return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,valueString];
            break;
    }
}
- (NSString *)displayRootStringWithArrayType:(NSObject *)value
{
    NSString * qualifierStr;
    NSString * typeStr;
    qualifierStr = @"strong";
    typeStr = @"NSArray";
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,value];
}

- (NSString *)displayRootStrDicWithkey:(NSString *)key
                              andValue:(NSObject *)value
{
    NSString * qualifierStr;
    NSString * typeStr;
    qualifierStr = @"strong";
    typeStr = self.replaceClassNames[key];
    if (!typeStr) {
        typeStr = [key capitalizedString];
    }
    ESClassInfo *info = [[ESClassInfo alloc] init];
    info.className = typeStr;
    info.classDic = (NSDictionary *)value;
    [self.classArray addObject:info];
    
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
}
#pragma mark -
#pragma Main Parsing Function

- (NSString *)formatWithKey:(NSString *)key value:(NSObject *)value{
    NSString * qualifierStr;
    NSString * typeStr;
    if ([value isKindOfClass:[NSString class]]) {
        
        return [self displayRootStringWithKeyStr:key];
        
    }else if([value isKindOfClass:[NSNumber class]]){
        
        return [self displayRootStringWithNumberType:key];
        
    }else if([value isKindOfClass:[NSArray class]]){
        
        NSArray *array = (NSArray *)value;
        ESClassInfo *info = [[ESClassInfo alloc] init];
        info.className = self.replaceClassNames[key];
        info.classDic = [array firstObject];
        [self.classArray addObject:info];
        return [self displayRootStringWithArrayType:value];
        
    }else if ([value isKindOfClass:[NSDictionary class]]){
        return [self displayRootStrDicWithkey:key andValue:value];
        
    }else if([value isKindOfClass:[@(YES) class]]){
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }
    return @"";
}

-(NSString *)parseClassWithClassInfo:(ESClassInfo *)classInfo{
    ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] initWithCreateToFile:self.createNewFile];
    engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
    ESFormatInfo *classFormatInfo = [engine parseWithDic:classInfo.classDic];
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n",classInfo.className];
    [result appendString:classFormatInfo.pasteboardContent];
    
    if (!self.isCreateNewFile) {
        NSMutableString *writeToMString = [NSMutableString string];
        if(self.formatInfo.writeToMContent)
            [writeToMString appendString:self.formatInfo.writeToMContent];
        [writeToMString appendFormat:@"\n@implementation %@\n\n@end\n",classInfo.className];
        self.formatInfo.writeToMContent = writeToMString;
        
        if (classFormatInfo.writeToMContent.length>0) {
            self.formatInfo.writeToMContent = [NSString stringWithFormat:@"%@%@",self.formatInfo.writeToMContent,classFormatInfo.writeToMContent];
        }
    }
    [self.formatInfo.classInfoArray addObjectsFromArray:classFormatInfo.classInfoArray];
    [self.formatInfo.classInfoArray addObject:classInfo];
    return result;
}


@end
