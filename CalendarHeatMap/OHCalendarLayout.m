//
//  OHCalendarLayout.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarLayout.h"

NSString* const OHCalendarLayoutSupplementaryKindMonthView = @"OHCalendarLayoutSupplementaryKindMonthView";


@interface OHCalendarLayout ()

@property (nonatomic, readwrite, copy) NSDate* startDateMidnight;
@property (nonatomic, readwrite, copy) NSDate* startDateWeek;
@property (nonatomic, readwrite, copy) NSDate* startDateMonth;
@property (nonatomic, readwrite, copy) NSDateComponents* startDateMidnightComponents;
@property (nonatomic, readwrite, copy) NSDate* endDateMidnight;
@property (nonatomic, readwrite, copy) NSDateComponents* endDateMidnightComponents;

@end


@implementation OHCalendarLayout

+ (Class)layoutAttributesClass
{
    return [OHCalendarViewLayoutAttributes class];
}

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

- (void)setLeftMargin:(CGFloat)leftMargin
{
    _leftMargin = leftMargin;
    [self invalidateLayout];
}

- (void)setRightMargin:(CGFloat)rightMargin
{
    _rightMargin = rightMargin;
    [self invalidateLayout];
}

- (NSDate*)dateForIndexPath:(NSIndexPath*)indexPath
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = indexPath.section;
    dateComponents.day = indexPath.item;
    // In the first section the start date != first day of month
    NSDate* startDate = indexPath.section == 0 ?
    self.startDateMidnight : self.startDateMonth;
    NSDate* date = [self.calendar dateByAddingComponents:dateComponents
                                                  toDate:startDate
                                                 options:0];
    return date;
}

- (NSIndexPath*)indexPathForDate:(NSDate *)date
{
    NSAssert([date timeIntervalSinceDate:self.startDateMidnight] >= 0, @"date %@ eariler than start date %@", date, self.startDateMidnight);
    NSAssert([date timeIntervalSinceDate:self.endDate] <= 0, @"date %@ after end date %@", date, self.endDate);
    
    NSDateComponents* dateComponents =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit
                     fromDate:date];
    
    NSUInteger units = NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents* components;
    
    // In the first section the start date != first day of month
    if(self.startDateMidnightComponents.year == dateComponents.year &&
       self.startDateMidnightComponents.month == dateComponents.month) {
        components = [self.calendar components:units
                                      fromDate:self.startDateMidnight
                                        toDate:date
                                       options:0];
    } else {
        components = [self.calendar components:units
                                      fromDate:self.startDateMonth
                                        toDate:date
                                       options:0];
    }
    
    NSInteger section = components.month;
    NSInteger item = components.day;
    return [NSIndexPath indexPathForItem:item inSection:section];
}

#pragma mark - UICollectionViewLayout extension

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}


@end
