//
//  OHCalendarHeatMapView.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-08.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, OHCalendarHeatMapViewScrollPosition) {
    OHCalendarHeatMapViewScrollPositionNone                 = 0,
    OHCalendarHeatMapViewScrollPositionTop                  = 1,
    OHCalendarHeatMapViewScrollPositionCenteredVertically   = 2,
    OHCalendarHeatMapViewScrollPositionBottom               = 3
};

@class OHCalendarHeatMapView;
@protocol OHCalenderHeatMapViewDataSource;
@protocol OHCalenderHeatMapViewDelegate;

@protocol OHCalenderHeatMapViewDataSource <NSObject>

@required

- (UIColor*)calendarHeatMapView:(OHCalendarHeatMapView*)calendarHeatMapView
                   colorForDate:(NSDate*)date;

@end

@protocol OCCalendarHeatMapViewDelegate <NSObject>

@optional

- (void)calendarHeatMapView:(OHCalendarHeatMapView*)calendarHeatMapView didSelectItemAtDate:(NSDate *)date;
- (void)calendarHeatMapView:(OHCalendarHeatMapView*)calendarHeatMapView didDeselectItemAtDate:(NSDate *)date;

@end

@interface OHCalendarHeatMapView : UIView

@property (nonatomic, weak) id<OHCalenderHeatMapViewDataSource> dataSource;
@property (nonatomic, weak) id<OHCalenderHeatMapViewDelegate> delegate;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic) BOOL allowsSelection;

- (NSArray*)datesForSelectedItems; // returns nil or an array of selected index dates
- (void)selectItemAtDate:(NSDate *)date animated:(BOOL)animated scrollPosition:(OHCalendarHeatMapViewScrollPosition)scrollPosition;
- (void)deselectItemAtDate:(NSDate *)date animated:(BOOL)animated;

- (void)reloadData; // discard the dataSource and delegate data and requery as necessary

- (void)scrollToItemAtDate:(NSDate *)date atScrollPosition:(OHCalendarHeatMapViewScrollPosition)scrollPosition animated:(BOOL)animated;


@end
