//
//  MapViewController.h
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "Data.h"
@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)setMap:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
- (IBAction)delete:(id)sender;
-(void)save;
-(void)load;
@end
