//
//  Data.h
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject
+(Data*)singleton;
@property (nonatomic) NSMutableArray* allList;
@property (nonatomic) NSString* tempCountry;
@property (nonatomic) NSMutableArray* listForPins;
@end
