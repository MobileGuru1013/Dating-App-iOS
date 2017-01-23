//
//  LocationPickerViewController.m
//  Project6
//
//  Created by superman on 3/12/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "LocationPickerViewController.h"
#import "Public.h"
#import <MapKit/MapKit.h>
#import "Pin.h"
#import "GlobalPool.h"

@interface LocationPickerViewController ()
{
    UILabel *lblAddress;
}
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) Pin *myPin;
@end

@implementation LocationPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Location";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(btnSaveClicked:)];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-50-64)];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addPin:)];
    recognizer.minimumPressDuration = 0.3;
    [self.mapView addGestureRecognizer:recognizer];
    
    [self.view addSubview:self.mapView];
    
    lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height-64-50, self.view.width, 50)];
    lblAddress.backgroundColor = COLOR_IN_DARK_GRAY;
    lblAddress.textColor = [UIColor whiteColor];
    lblAddress.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:lblAddress];
    
    self.myPin = [[Pin alloc] initWithCoordinate:[GlobalPool sharedInstance].location.coordinate];
    [self.mapView addAnnotation:self.myPin];
    
    [self displayAddress:[GlobalPool sharedInstance].location];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnSaveClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(saveBtnClicked:location:)]) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.myPin.coordinate.latitude longitude:self.myPin.coordinate.longitude];
        [self.delegate saveBtnClicked:lblAddress.text location:loc];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addPin:(UIGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint userTouch = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D mapPoint = [self.mapView convertPoint:userTouch toCoordinateFromView:self.mapView];
    // and add it to our view
    Pin *newPin = [[Pin alloc]initWithCoordinate:mapPoint];
    [self.mapView removeAnnotation:self.myPin];
    self.myPin = newPin;
    [self.mapView addAnnotation:self.myPin];
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:mapPoint.latitude longitude:mapPoint.longitude];
    [self displayAddress:loc];
}
- (void) displayAddress:(CLLocation*) location {
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
//        NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@", placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
        NSString *city;
        if([placemark.addressDictionary objectForKey:@"SubAdministrativeArea"] != NULL)
            city = [placemark.addressDictionary objectForKey:@"SubAdministrativeArea"];
        else if([placemark.addressDictionary objectForKey:@"City"] != NULL)
            city = [placemark.addressDictionary objectForKey:@"City"];
        else if([placemark.addressDictionary objectForKey:@"Country"] != NULL)
            city = [placemark.addressDictionary objectForKey:@"Country"];
        else
            city = @"City Not Specified";
        if([placemark.addressDictionary objectForKey:@"City"] != NULL)
            city = [placemark.addressDictionary objectForKey:@"City"];
        else
            city = @"City N/A";
        lblAddress.text = [NSString stringWithFormat:@"%@",city];
        
    }];
//    [self updateMapView:location];

}
- (void)updateMapView:(CLLocation *)location {
    
    // create a region and pass it to the Map View
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.latitudeDelta = 0.001;
    region.span.longitudeDelta = 0.001;
    
    [self.mapView setRegion:region animated:YES];
}
@end
