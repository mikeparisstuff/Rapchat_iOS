//
//  RCSearchFriendsViewController.h
//  Rapchat
//
//  Created by Michael Paris on 1/5/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTableViewController.h"

@interface RCSearchPeopleViewController : RCTableViewController <UISearchDisplayDelegate, UISearchBarDelegate>
{
    BOOL isSearching;
    
}


@end
