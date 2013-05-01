//
//  OHCalendarLayout.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarLayout.h"

@interface OHCalendarLayout ()

@property (nonatomic, readwrite, copy) NSDate* startDateMidnight;
@property (nonatomic, readwrite, copy) NSDate* startDateWeek;
@property (nonatomic, readwrite, copy) NSDate* startDateMonth;
@property (nonatomic, readwrite, copy) NSDateComponents* startDateMidnightComponents;
@property (nonatomic, readwrite, copy) NSDate* endDateMidnight;
@property (nonatomic, readwrite, copy) NSDateComponents* endDateMidnightComponents;

@end


@implementation OHCalendarLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _calendar = [NSCalendar autoupdatingCurrentCalendar];
    
}

- (void)setStartDate:(NSDate *)startDate
{
    _startDate = [startDate copy];
    if (!startDate) {
        self.startDateMidnight = nil;
        self.startDateMidnightComponents = nil;
        self.startDateWeek = nil;
        self.startDateMonth = nil;
        [self invalidateLayout];
        return;
    }
    
    NSCalendar* cal = self.calendar;
    
    // Store away midnight
    NSUInteger midnightUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* startComponents = [cal components:midnightUnits fromDate:_startDate];
    self.startDateMidnight = [cal dateFromComponents:startComponents];
    self.startDateMidnightComponents = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:_startDateMidnight];
    
    // Find the first day of the week of the start date (this is our [0,0] cell).
    NSDateComponents* weekdayComponents = [cal components:NSWeekdayCalendarUnit fromDate:_startDateMidnight];
    if (weekdayComponents.weekday == 1) {
        self.startDateWeek = _startDateMidnight;
    } else {
        NSDateComponents* adjustment = [[NSDateComponents alloc] init];
        adjustment.day = 1 - weekdayComponents.weekday;
        self.startDateWeek = [cal dateByAddingComponents:adjustment toDate:_startDateMidnight options:0];
    }
    
    // Find the first day of the month of the start date (used for index path to date calculation)
    NSDateComponents* monthComponents = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:_startDateMidnight];
    self.startDateMonth = [cal dateFromComponents:monthComponents];
    
    [self invalidateLayout];
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = [endDate copy];
    if (!endDate) {
        self.endDateMidnight = nil;
        self.endDateMidnightComponents = nil;
        [self invalidateLayout];
        return;
    }
    
    NSCalendar* cal = self.calendar;
    
    NSUInteger midnightUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* endComponents = [cal components:midnightUnits fromDate:_endDate];
    self.endDateMidnight = [cal dateFromComponents:endComponents];
    self.endDateMidnightComponents = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:_endDateMidnight];
    
    [self invalidateLayout];
}

- (void)setCalendar:(NSCalendar *)calendar
{
    _calendar = [calendar copy];
    if (!_calendar) {
        _calendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    [self setStartDate:_startDate];
    [self setEndDate:_endDate];
    [self invalidateLayout];
}

- (void)setCellSize:(CGSize)cellSize
{
    _cellSize = cellSize;
    [self invalidateLayout];
}

#pragma mark - UICollectionViewLayout extension

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

#pragma mark - Utility

- (NSInteger)numberOfDaysInMonth:(NSDate*)date
{
    NSDateComponents* components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSInteger numberOfItems = 0;
    if (components.year == self.endDateMidnightComponents.year && components.month == self.endDateMidnightComponents.month) {
        // Last month
        numberOfItems = components.day + 1;
    } else {
        NSRange daysOfMonth = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                                  inUnit:NSMonthCalendarUnit
                                                 forDate:date];
        if (components.year == self.startDateMidnightComponents.year && components.month == self.startDateMidnightComponents.month) {
            // First month
            numberOfItems = daysOfMonth.length - components.day + 1;
        } else {
            // somewhere in the middle
            numberOfItems = daysOfMonth.length;
        }
    }
    
    return numberOfItems;
}

@end
