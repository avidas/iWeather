//
//  FirstViewController.m
//  Weather
//  Search location, display on mapview with weather from forecast.io and save in core data
//
//  Created by Das, Ananya on 7/26/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

#import "FirstViewController.h"
#import "WeatherAnnotation.h"
#import "AppDelegate.h"
#import "CityTemperature.h"

@interface FirstViewController ()
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionTask *dataTask;
@end

@implementation FirstViewController

- (NSURLSession *)session {
    if (!_session) {
        // Initialize Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Configure Session Configuration
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
        // Initialize Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    
    return _session;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.placeSearch.delegate = self;
    self.mapView.delegate = self;
    
    //hide keyboard when area outside search bar tapped
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self showUserLocation];
}

-(void)hideKeyBoard {
    [self.placeSearch resignFirstResponder];
}

- (void) showUserLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.mapView setShowsUserLocation:YES];
}

- (NSURL *)urlForLatLon:(double)latitude :(double)longitude {
    NSString *baseURL = @"https://api.forecast.io";
    NSString *urlString = [baseURL stringByAppendingString:@"/forecast/1027bf1efa722adb7bac23870e7fc773/"];
    urlString = [urlString stringByAppendingFormat:@"%f,%f", latitude, longitude];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (CLLocationCoordinate2D)getLocation:(NSArray *)placemarks
{
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    CLLocationCoordinate2D newLocation = [placemark.location coordinate];
    return newLocation;
}

- (void)getWeatherData:(CLLocationCoordinate2D) location
{
    //get weather data for newLocation
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    self.dataTask = [self.session dataTaskWithURL:[self urlForLatLon:location.latitude :location.longitude] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSDictionary *results;
            if ([json isKindOfClass:[NSDictionary class]]) {
                results = json;
            }
            else if ([json isKindOfClass:[NSArray class]]) {
            }
            else {
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //Drop pin
                WeatherAnnotation *annotation = [[WeatherAnnotation alloc] init];
                annotation.title = self.placeSearch.text;
                NSString *currentTemperature = [NSString stringWithFormat:@"Temperature: %@ F", [[results objectForKey:@"currently"] objectForKey:@"temperature"]];
                //currentTemperature = [currentTemperature substringToIndex:];
                annotation.subtitle = currentTemperature;
                annotation.coordinate = location;
                [self.mapView addAnnotation:annotation];
                [self.mapView selectAnnotation:annotation animated:YES];
                
                //Set visible area of the map around new pin
                [self displayMapVisibleArea:[annotation coordinate]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self addLocation:self.placeSearch.text Temperature:currentTemperature];
                });
            });
        });
    }];
    if (self.dataTask) {
        [self.dataTask resume];
    }
}

- (void)addLocation:(NSString *)location Temperature:(NSString *)temperature
{
    NSError *error;
    
    //get managed context from app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    //set up fetch request for location passed
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"CityTemperature" inManagedObjectContext:context];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", location];
    [request setPredicate:pred];
    
    //update if entry already exists otherwise create new entry
    //can be consolidated better
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound) {
        NSLog(@"Error: %@", error);
    } else if (count == 0){
        CityTemperature *cityTemp = (CityTemperature *)[NSEntityDescription insertNewObjectForEntityForName:@"CityTemperature" inManagedObjectContext:context];
        [cityTemp setName:location];
        [cityTemp setTemperature:temperature];
    } else {
        NSArray *items = [context executeFetchRequest:request error:&error];
        
        for (CityTemperature *cityTemp in items) {
            [cityTemp setTemperature:temperature];
        }
    }
    
    if (![context save:&error]){
        NSLog(@"Error: %@", error);
        exit(-1);
    }
}

- (void)displayMapRegion:(CLLocationCoordinate2D) location
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 8000, 8000);
    [self.mapView setRegion:region animated:YES];
}

- (void)displayMapVisibleArea:(CLLocationCoordinate2D) location
{
    MKMapRect visibleMap = [self.mapView visibleMapRect]; //get visible map area
    MKMapPoint annotCoordinate = MKMapPointForCoordinate(location); //get annotation coordinate
    visibleMap.origin.x = annotCoordinate.x - visibleMap.size.width * 0.5;
    visibleMap.origin.y = annotCoordinate.y - visibleMap.size.height * 0.25;
    [self.mapView setVisibleMapRect:visibleMap animated:YES];
}

- (void)showLocationTempMap
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.placeSearch.text completionHandler:^(NSArray *placemarks, NSError *error){
        
        //Set map visible area to location entered in search bar
        CLLocationCoordinate2D newLocation = [self getLocation:placemarks];
        [self displayMapRegion:newLocation];
        [self getWeatherData:newLocation];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //dismiss keyboard after search pressed
    [self.placeSearch resignFirstResponder];
    
    [self showLocationTempMap];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    static NSString *pinIdentifier = @"com.avidas.pin";
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    if (pin==nil){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
    }
    pin.pinColor = MKPinAnnotationColorGreen;
    pin.enabled = YES;
    pin.canShowCallout = YES;
    pin.animatesDrop = YES;
    
    return pin;
}

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
