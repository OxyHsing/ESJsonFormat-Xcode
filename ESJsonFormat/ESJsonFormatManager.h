//
//  ESJsonFormatManager.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, ESFormatNullTypeSetting){
    ESFormatNullType_ToString = 0,
    ESFormatNullType_ToNumber,
    ESFormatNullType_To
};

/**
 *  Define how JSON number, bool value mapping to corresponding type of NSObject
 */
typedef NS_ENUM(NSUInteger, ESFormatNumberType){
    /**
     *  Map JSON numbers, Bool to non-nsobject type
     *  Directly C-Value
     */
    ESFormatNumber_DirectType = 0,
    /**
     *  Map JSON Numbers to NSNumber
     *  <For better conversion by NSJSONSerialization>
     */
    ESFormatNumber_BoxType
};

typedef NS_ENUM(NSUInteger, ESFormatMemMgntType) {
    ESFormatMemMgntType_Copy = 0,
    ESFormatMemMgntType_StrongRef,
    ESFormatMemMgntType_WeakRef,
    ESFormatMemMgntType_Assign
};



@class ESFormatInfo;
@interface ESJsonFormatManager : NSObject
 
@property (nonatomic, strong) NSDictionary *replaceClassNames;
@property (nonatomic, assign, getter=isCreateNewFile) BOOL createNewFile;

@property (nonatomic, assign) ESFormatMemMgntType memMgnType;
@property (nonatomic, assign) ESFormatNumberType formatNumberType;

-(instancetype)initWithCreateToFile:(BOOL)createToFile;
- (ESFormatInfo *)parseWithDic:(NSDictionary *)dic;
@end
