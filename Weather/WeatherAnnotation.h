//
//  WeatherAnnotation.h
//  Weather
//
//  Created by Das, Ananya on 7/26/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

@import MapKit;
#import <Foundation/Foundation.h>

@interface WeatherAnnotation : NSObject <MKAnnotation>

//these must have names title and subtitle
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

//assign as we want to change it
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
