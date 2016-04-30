//
//  MapViewController.m
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak) MKAnnotationView *tempAnnotationView;
@property(nonatomic)NSString* tempLatitude;
@property(nonatomic)NSString* tempLongitude;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self addGestureRecogniserToMapView];
    self.tempAnnotationView = nil;
    self.tempLatitude=@"";
    self.tempLongitude=@"";
    
    //sets images to the segmented controller
    UIImage *standard = [[UIImage imageNamed:@"standard.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *satellite = [[UIImage imageNamed:@"satellite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *hybrid = [[UIImage imageNamed:@"hybrid.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_mySegmentedControl setImage:standard forSegmentAtIndex:0];
    [_mySegmentedControl setImage:satellite forSegmentAtIndex:1];
    [_mySegmentedControl setImage:hybrid forSegmentAtIndex:2];
    
    //deletes lines
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, self.mySegmentedControl.frame.size.height), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.mySegmentedControl setDividerImage:blank
                    forLeftSegmentState:UIControlStateNormal
                      rightSegmentState:UIControlStateNormal
                             barMetrics:UIBarMetricsDefault];
}

// adds pins to the map if there are pins on the saved list.
-(void)viewDidAppear:(BOOL)animated{
    
    if ([Data singleton].listForPins != nil) {
        
        for (NSMutableDictionary* pin in [Data singleton].listForPins) {
            MapPin *toAdd = [[MapPin alloc]init];
            toAdd.coordinate = CLLocationCoordinate2DMake([[pin objectForKey:@"latitude"] floatValue],
                                                          [[pin objectForKey:@"longitude"] floatValue]);
            toAdd.subtitle = [pin objectForKey:@"subtitle"];
            toAdd.title = [pin objectForKey:@"title"];
            
            [self.mapView addAnnotation:toAdd];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// long press to add a pin
- (void)addGestureRecogniserToMapView{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(addPinToMap:)];
    lpgr.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:lpgr];
    
}

- (void)addPinToMap:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    NSLog(@"test for coodinate %f , %f",touchMapCoordinate.latitude,touchMapCoordinate.longitude);
    
    //adds a pin to the List
    NSMutableDictionary* pin = @{@"title":@"",
                                 @"subtitle":@"",
                                 @"latitude":[NSString stringWithFormat: @"%f", touchMapCoordinate.latitude],
                                 @"longitude":[NSString stringWithFormat: @"%f", touchMapCoordinate.longitude]}.mutableCopy;
    
    //gets the location
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    __block NSString* country=@"";
    
    __block MapPin *toAdd = [[MapPin alloc]init];
    toAdd.coordinate = touchMapCoordinate;
    toAdd.subtitle = @"";
    toAdd.title = @"...loading";
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                  // Give Country Name
                  country = [NSString stringWithFormat:@"%@",placemark.country];
                  
                  //Print the location to console
                  NSLog(@"I am currently at %@",locatedAt);
                  
                  toAdd.title = [NSString stringWithFormat:@"%@",placemark.country];
                  [pin setValue:placemark.country forKey:@"title"];
                  
                  if (placemark.locality != nil) {
                      toAdd.subtitle = [NSString stringWithFormat:@"%@",placemark.locality];
                      [pin setValue:placemark.locality forKey:@"subtitle"];
                  }else{
                      toAdd.subtitle = [NSString stringWithFormat:@"%@",placemark.name];
                      [pin setValue:placemark.name forKey:@"subtitle"];
                  }
              }
     ];
     [self.mapView addAnnotation:toAdd];
     [[Data singleton].listForPins addObject:pin];
}

// adds a button to the annotation
- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views{
    // gets annotaion view
    for (MKAnnotationView* annotationView in views) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame =CGRectMake(30, 30, 30, 30);
        [button setImage:[UIImage imageNamed:@"list.jpg"] forState:UIControlStateNormal];

        //adds a button
        annotationView.leftCalloutAccessoryView = button;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"list"];
    [Data singleton].tempCountry = view.annotation.title;
    [self presentViewController:vc animated:YES completion:nil];
    
}

// action when a user clicks on a pin
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    self.deleteButton.hidden = NO;
    self.tempAnnotationView = view;
    self.tempLatitude = [NSString stringWithFormat:@"%f",view.annotation.coordinate.latitude];
    self.tempLongitude = [NSString stringWithFormat:@"%f",view.annotation.coordinate.longitude];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// a method for standard, satellite and hybrid views
- (IBAction)setMap:(id)sender {
    
    switch (((UISegmentedControl*)sender).selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (IBAction)tap:(id)sender {
    self.deleteButton.hidden=YES;
}

- (IBAction)delete:(id)sender {
    //if the user deletes all pins in one country in which the user made a packing list,
    //that country is deleted from allList.
    int i = 0;
   
    NSArray *allAnnotations = self.mapView.annotations;
    NSString *tempTitle = self.tempAnnotationView.annotation.title;
    NSString *tempSub = self.tempAnnotationView.annotation.subtitle;
    
    for (NSDictionary* pin in [Data singleton].listForPins) {
        if ([[pin objectForKey:@"title"] isEqualToString:tempTitle]) {
            i++;
        }
    }
    
    if (i==1) {
        NSDictionary* country;
        
        for (NSDictionary* one in [Data singleton].allList){
            if ([[one objectForKey:@"country"] isEqualToString:tempTitle] ) {
                country = one;
            }
        }
        [[Data singleton].allList removeObject:country];
    }
    
    if (self.tempAnnotationView.annotation != nil) {
        //deletes a pin from the list
        for (long i = [Data singleton].listForPins.count-1; i >=0 ; i--) {
            if ([[[Data singleton].listForPins[i] objectForKey:@"title"]isEqualToString:tempTitle] &&
                [[[Data singleton].listForPins[i] objectForKey:@"subtitle"]isEqualToString:tempSub]){
                
                 [[Data singleton].listForPins removeObjectAtIndex:i];
            }
        }
    }
    
    //deletes a pin from the map
    if (self.tempAnnotationView.annotation != nil) {
        int i =0;
        
        for(MapPin *pickedAnnotation in allAnnotations) {
            
            if([pickedAnnotation.title isEqualToString:tempTitle]&&
               [pickedAnnotation.subtitle isEqualToString:tempSub]) {
                
                i++;
                
                [self.mapView removeAnnotation:pickedAnnotation];
                self.deleteButton.hidden = YES;
            }
        }
    }
}

-(void)save{
    NSUserDefaults *settings =[NSUserDefaults standardUserDefaults];
    Data *data = [Data singleton];
    [settings setObject:data.allList.copy forKey:@"savedData"];
    [settings setObject:data.listForPins.copy forKey:@"pins"];
    [settings synchronize];
}


-(void)load{
    NSUserDefaults *settings =[NSUserDefaults standardUserDefaults];
    NSArray* savedData = [settings objectForKey:@"savedData"];
    NSArray* pins = [settings objectForKey:@"pins"];
    
    if (savedData != nil) {
        for ( int i =0; i < savedData.count; i++) {
            NSMutableDictionary* oneList =[savedData objectAtIndex:i];
            oneList = oneList.mutableCopy;
            [[Data singleton].allList addObject:oneList];
        }
    }
    
    if (pins != nil) {
        [Data singleton].listForPins = pins.mutableCopy;
    }
}
@end
