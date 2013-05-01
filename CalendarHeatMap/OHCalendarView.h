//
//  OHCalendarView.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-21.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHCalendarLayout.h"
#import "OHCalendarWeekLayout.h"
#import "OHCalendarMonthLayout.h"
#import "OHCalendarDayLayout.h"

typedef NS_OPTIONS(NSUInteger, OHCalendarViewScrollPosition) {
    OHCalendarViewScrollPositionNone                 = UICollectionViewScrollPositionNone,
    OHCalendarViewScrollPositionTop                  = UICollectionViewScrollPositionTop,
    OHCalendarViewScrollPositionCenteredVertically   = UICollectionViewScrollPositionCenteredVertically,
    OHCalendarViewScrollPositionBottom               = UICollectionViewScrollPositionBottom
};

@class OHCalendarView;
@protocol OHCalendarViewDataSource;
@protocol OHCalendarViewDelegate;

@protocol OHCalendarViewDataSource <NSObject>

@optional
// Using custom cells
- (UICollectionViewCell*)calendarView:(OHCalendarView*)calendarView cellForDate:(NSDate*)date;

// Using default cells
- (UIColor*)calendarView:(OHCalendarView*)calendarView backgroundColorForDate:(NSDate*)date;
- (NSString*)calendarView:(OHCalendarView*)calendarView labelForDate:(NSDate*)date;

@end

@protocol OHCalendarViewDelegate <NSObject>

@optional
- (void)calendarView:(OHCalendarView*)calendarView didSelectItemAtDate:(NSDate*)date;
- (void)calendarView:(OHCalendarView*)calendarView didDeselectItemAtDate:(NSDate*)date;

@end

@interface OHCalendarView : UIView

@property (nonatomic, weak) id<OHCalendarViewDataSource> dataSource;
@property (nonatomic, weak) id<OHCalendarViewDelegate> delegate;
@property (nonatomic, strong) OHCalendarLayout* calendarLayout;
@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* endDate;
@property (nonatomic, copy) NSCalendar* calendar;
@property (nonatomic) BOOL showMonths;
@property (nonatomic) BOOL showDayLabel;

- (id)initWithFrame:(CGRect)frame calendarLayout:(OHCalendarLayout*)layout;

- (NSArray*)datesForSelectedItems; // returns nil or an array of selected index dates
- (void)selectItemAtDate:(NSDate *)date animated:(BOOL)animated scrollPosition:(OHCalendarViewScrollPosition)scrollPosition;
- (void)deselectItemAtDate:(NSDate *)date animated:(BOOL)animated;

- (void)reloadData; // discard the dataSource and delegate data and requery as necessary

- (void)scrollToItemAtDate:(NSDate *)date atScrollPosition:(OHCalendarViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier;

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forDate:(NSDate*)date;
- (id)dequeueReusableSupplementaryViewOfKind:(NSString*)elementKind withReuseIdentifier:(NSString *)identifier forDate:(NSDate*)date;


- (void)setCollectionViewLayout:(OHCalendarLayout*)layout animated:(BOOL)animated;
@end
