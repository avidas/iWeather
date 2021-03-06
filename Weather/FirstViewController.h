//
//  FirstViewController.h
//  Weather
//
//  Created by Das, Ananya on 7/26/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FirstViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *placeSearch;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
