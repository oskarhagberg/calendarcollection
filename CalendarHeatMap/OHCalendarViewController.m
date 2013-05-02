//
//  OHCalendarViewController.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-21.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarViewController.h"
#import "OHCalendarView.h"

@interface OHCalendarViewController () <OHCalendarViewDataSource, OHCalendarViewDelegate>

@property (nonatomic, weak) OHCalendarView* calendarView;
@property (nonatomic, strong) OHCalendarWeekLayout* weekLayout;
@property (nonatomic, strong) OHCalendarDayLayout* dayLayout;

@end

@implementation OHCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    OHCalendarWeekLayout* weekLayout = [[OHCalendarWeekLayout alloc] init];
    weekLayout.leftMargin = 80.0;
    weekLayout.rightMargin = weekLayout.leftMargin;
    self.weekLayout = weekLayout;
    
    OHCalendarDayLayout* dayLayout = [[OHCalendarDayLayout alloc] init];
    dayLayout.leftMargin = 149.0;
    dayLayout.rightMargin = dayLayout.leftMargin;
    self.dayLayout = dayLayout;
    
    OHCalendarView* calendarView = [[OHCalendarView alloc] initWithFrame:self.view.bounds
                                                          calendarLayout:weekLayout];
    
    calendarView.endDate = [NSDate date];
    NSDateComponents* oneYearAgo = [[NSDateComponents alloc] init];
    oneYearAgo.year = -1;
    calendarView.startDate = [calendarView.calendar dateByAddingComponents:oneYearAgo
                                                                    toDate:calendarView.endDate
                                                                   options:0];
    
    calendarView.delegate = self;
    calendarView.dataSource = self;
    calendarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    calendarView.backgroundColor = [UIColor whiteColor];
    calendarView.showDayLabel = YES;
    [self.view addSubview:calendarView];
    self.calendarView = calendarView;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)tapped
{
    if (self.calendarView.calendarLayout == self.weekLayout) {
        [self.calendarView setCalendarViewLayout:self.dayLayout animated:YES];
    } else {
        [self.calendarView setCalendarViewLayout:self.weekLayout animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OHCalendarViewDataSource implementation

- (UIColor*)calendarView:(OHCalendarView*)calendarView backgroundColorForDate:(NSDate*)date
{
    NSDateComponents* components = [calendarView.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    if (components.day == 1) {
        return [UIColor yellowColor];
    }
    return [self randomHSBColor];
}

#define ranged_random(min, max) ((float)rand()/RAND_MAX * (max-min)+min)

- (UIColor*)randomRGBColor
{
    
    float r = ranged_random(0.0, 1.0);
    float g = ranged_random(0.0, 1.0);
    float b = ranged_random(0.0, 1.0);
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

#define ARC4RANDOM_MAX      0x100000000
- (UIColor*)randomHSBColor
{
    double h = ranged_random(0.2, 0.2);
    double s = ranged_random(0.0, 0.4);
    double b = ranged_random(0.8, 1.0);
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:1.0];
}

#pragma mark - OHCalendarViewDelegate implementation

@end
