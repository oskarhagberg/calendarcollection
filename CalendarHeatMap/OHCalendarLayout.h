//
//  OHCalendarLayout.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHCalendarViewLayoutAttributes.h"

@interface OHCalendarLayout : UICollectionViewLayout 

@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* endDate;
@property (nonatomic, copy) NSCalendar* calendar;
@property (nonatomic) CGSize cellSize;


// Internal use (should it be moved somewhere else?
@property (nonatomic) CGSize contentSize;
@property (nonatomic, readonly, copy) NSDate* startDateMidnight;
@property (nonatomic, readonly, copy) NSDate* startDateWeek;
@property (nonatomic, readonly, copy) NSDate* startDateMonth;
@property (nonatomic, readonly, copy) NSDateComponents* startDateMidnightComponents;
@property (nonatomic, readonly, copy) NSDate* endDateMidnight;

@end

@interface OHCalendarLayout (SubclassingHooks)

- (NSDate*)dateForIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)indexPathForDate:(NSDate*)date;

@end