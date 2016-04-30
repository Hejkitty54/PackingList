//
//  Data.m
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import "Data.h"

@implementation Data

+(Data*)singleton{
    static Data *singletonData = nil;
    
    if(!singletonData){
        singletonData = [[super allocWithZone:nil]init];
    }
    return singletonData;
}

+(id) allocWithZone:(NSZone *)zone{
    return [self singleton];
}

- (id)init {
    if (self = [super init]) {
        self.allList = [[NSMutableArray alloc]init];
        self.listForPins = [[NSMutableArray alloc]init];
        NSLog(@"initialize");        
    }
    return self;
}
@end
