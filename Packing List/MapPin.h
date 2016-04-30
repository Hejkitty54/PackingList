//
//  MapPin.h
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation>
@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString * subtitle;
@property (nonatomic,assign)CLLocationCoordinate2D coordinate;
@end
