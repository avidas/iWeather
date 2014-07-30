//
//  CityTemperature.h
//  Weather
//
//  Created by Das, Ananya on 7/29/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CityTemperature : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * temperature;

@end
