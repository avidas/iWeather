//
//  HistoryTableViewController.h
//  Weather
//
//  Created by Das, Ananya on 8/2/14.
//  Copyright (c) 2014 Das, Ananya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray *results;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;

@end
