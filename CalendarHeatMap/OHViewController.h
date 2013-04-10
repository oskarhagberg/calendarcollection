//
//  OHViewController.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-08.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHCalendarHeatMapView.h"

@interface OHViewController : UIViewController

@property (weak, nonatomic) IBOutlet OHCalendarHeatMapView *calendarHeatMap;
@end
