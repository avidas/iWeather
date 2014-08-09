//
//  DetailViewController.h
//  Weather
//
//  Created by Das, Ananya on 8/2/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityTemperature.h"

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) CityTemperature *detailCityTemp;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@end
