//
//  DetailViewController.m
//  Weather
//
//  Created by Das, Ananya on 8/2/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailLabel.text = [self.detailCityTemp name];
    self.temperatureLabel.text = [self.detailCityTemp temperature];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
