//
//  OHCalendarViewController.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-21.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OHCalendarViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *calendarWrapperView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)showMonthLayout:(id)sender;
- (IBAction)showWeekLayout:(id)sender;
- (IBAction)showDayLayout:(id)sender;

@end
