//
//  OHCalendarHeatMapView.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-08.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarHeatMapView.h"


static NSString* const kOHCalendarHeatMapKindDay = @"OHCalendarHeatMapKindDay";
static NSString* const kOHCalendarHeatMapKindMonth = @"OHCalendarHeatMapKindMonth";

@interface OHCalendarHeatMapLayout : UICollectionViewLayout

@property (nonatomic) CGSize cellSize;
@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* startDateMidnight;
@property (nonatomic, copy) NSDate* startDateWeek;
@property (nonatomic, copy) NSDate* startDateMonth;
@property (nonatomic, copy) NSDate* endDate;
@property (nonatomic, copy) NSDate* endDateMidnight;
@property (nonatomic, strong) NSCalendar* calendar;

@property (nonatomic) CGRect layedOutRect;
@property (nonatomic, copy) NSArray* layoudOutAttributes;

@property (nonatomic) CGSize contentSize;

@end

@implementation OHCalendarHeatMapLayout

- (void)prepareLayout
{
    
    self.cellSize = CGSizeMake(40.0, 40.0);
        
    // Store away midnight for start and end date
    NSUInteger midnightUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* startComponents = [self.calendar components:midnightUnits fromDate:self.startDate];
    self.startDateMidnight = [self.calendar dateFromComponents:startComponents];
    NSDateComponents* endComponents = [self.calendar components:midnightUnits fromDate:self.endDate];
    self.endDateMidnight = [self.calendar dateFromComponents:endComponents];
    
    // Find the first day of the week of the start date (this is our [0,0] cell).
    NSDateComponents* weekdayComponents = [self.calendar components:NSWeekdayCalendarUnit fromDate:self.startDateMidnight];
    if (weekdayComponents.weekday == 1) {
        self.startDateWeek = self.startDateMidnight;
    } else {
        NSDateComponents* adjustment = [[NSDateComponents alloc] init];
        adjustment.day = 1 - weekdayComponents.weekday;
        self.startDateWeek = [self.calendar dateByAddingComponents:adjustment toDate:self.startDateMidnight options:0];
    }
    
    // Find the first day of the month of the start date (used for index path to date calculation)
    NSDateComponents* monthComponents = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self.startDateMidnight];
    self.startDateMonth = [self.calendar dateFromComponents:monthComponents];
    
    // Count how many weeks between start and end date. This is how many rows we will have
    NSDateComponents* components = [self.calendar components:NSWeekCalendarUnit
                                                    fromDate:self.startDateWeek
                                                      toDate:self.endDateMidnight options:0];
    NSInteger rows = components.week + 1;
    CGFloat height = rows * self.cellSize.height;
    self.contentSize = CGSizeMake(7 * self.cellSize.width, height);
}

- (NSDate*)dateForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger month = indexPath.section;
    NSInteger day = indexPath.item;
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = month;
    dateComponents.day = day;
    NSDate* date;
    if (indexPath.section == 0) {
        date = [self.calendar dateByAddingComponents:dateComponents toDate:self.startDateMidnight options:0];
    } else {
        date = [self.calendar dateByAddingComponents:dateComponents toDate:self.startDateMonth options:0];
    }
    return date;
}

- (NSIndexPath*)indexPathForDate:(NSDate*)date
{
    NSDateComponents* startComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.startDateMidnight];
    NSDateComponents* dateComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];

    NSUInteger units = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* components;
    
    if (startComponents.year == dateComponents.year && startComponents.month == dateComponents.month) {
        components = [self.calendar components:units fromDate:self.startDateMidnight toDate:date options:0];
    } else {
        components = [self.calendar components:units fromDate:self.startDateMonth toDate:date options:0];
    }    
    return [NSIndexPath indexPathForItem:components.day inSection:components.month];
}

- (CGRect)rectForDate:(NSDate*)date
{
    static const NSTimeInterval secondsInDay = 60.0 * 60.0 * 24.0;
    static const NSTimeInterval secondsInWeek = secondsInDay * 7.0;
    
    NSTimeInterval interval = [date timeIntervalSinceDate:self.startDateWeek];
    
    NSInteger row = interval / secondsInWeek;
    NSInteger column = (interval - row * secondsInWeek) / secondsInDay;
    
    NSLog(@"Date: %@, [%d,%d]", date, row, column);
    
    CGFloat y = row * 40.0;
    CGFloat x = column * 40.0;
    
    return CGRectMake(x, y, 40.0, 40.0);
}

#pragma mark - UICollectionViewLayout methods

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    if (self.layoudOutAttributes && CGRectEqualToRect(rect, self.layedOutRect)) {
        return self.layoudOutAttributes;
    }
    
    NSMutableArray* attributes = [NSMutableArray array];
    
    NSInteger previousRows = (NSInteger)(rect.origin.y/self.cellSize.height);
    
    NSDateComponents* previousWeeks = [[NSDateComponents alloc] init];
    previousWeeks.week = previousRows;
    
    NSDateComponents* oneDayAfter = [[NSDateComponents alloc] init];
    oneDayAfter.day = 1;
    
    NSDate* date = [self.calendar dateByAddingComponents:previousWeeks toDate:self.startDateWeek options:0];
    NSDate* start = [date copy];
    
    CGFloat x = 0.0;
    CGFloat y = previousRows * self.cellSize.height;
    
    while (y < rect.origin.y + rect.size.height) {
        
        for (NSInteger column = 0; column < 7; column ++) {
            
            CGRect frame = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
            //Sanity check
            if (CGRectIntersectsRect(frame, rect) &&
                [date timeIntervalSinceDate:self.startDateMidnight] >= 0 &&
                [date timeIntervalSinceDate:self.endDateMidnight] <= 0) {
                
                NSIndexPath* indexPath = [self indexPathForDate:date];

                UICollectionViewLayoutAttributes* attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attr.frame = frame;
                attr.zIndex = 1;
                [attributes addObject:attr];
                
                /* Debug
                static NSDateFormatter* formatter;
                if (!formatter) {
                    formatter = [[NSDateFormatter alloc] init];
                    [formatter setTimeZone:[self.calendar timeZone]];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                }
                NSLog(@"[%d,%d] [%f,%f] <%@>", indexPath.section, indexPath.item, frame.origin.x, frame.origin.y, [formatter stringFromDate:date]);
                 */

                
                if (indexPath.item == 0) {
                    UICollectionViewLayoutAttributes* monthAttr =
                    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kOHCalendarHeatMapKindMonth
                                                                                   withIndexPath:indexPath];
                    CGRect monthFrame = CGRectMake(0.0, frame.origin.y, self.contentSize.width, 80.0);
                    monthAttr.frame = monthFrame;
                    monthAttr.zIndex = 2;
                    [attributes addObject:monthAttr];
                }
            }
            
            date = [self.calendar dateByAddingComponents:oneDayAfter toDate:date options:0];
            x += self.cellSize.width;
        }
        
        x = 0;
        y += self.cellSize.height;
        
    }
    
    /* Debug
    NSLog(@"Layed out between %f and %f and created %d attributes between %@ and %@",
          rect.origin.y, rect.origin.y + rect.size.height,
          attributes.count, start, date);
     */
    self.layedOutRect = rect;
    self.layoudOutAttributes = attributes;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    abort();
    NSDate* date = [self dateForIndexPath:indexPath];
    CGRect rect = [self rectForDate:date];
    UICollectionViewLayoutAttributes* attr =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attr.frame = rect;
    attr.zIndex = 1;
    return attr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    abort();
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    abort();
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    return proposedContentOffset;
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

@end

@interface OHCalendarHeatMapDayCell : UICollectionViewCell

@property (nonatomic, weak, readonly) UILabel* label;

@end

@implementation OHCalendarHeatMapDayCell

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    UILabel* label = [[UILabel alloc] initWithFrame:self.frame];
    label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label];
    _label = label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _label.frame = self.contentView.bounds;
}

@end

@interface OHCalendarHeatMapMonthView : UICollectionReusableView

@property (nonatomic, weak, readonly) UILabel* label;

@end

@implementation OHCalendarHeatMapMonthView

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    UILabel* label = [[UILabel alloc] initWithFrame:self.frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor greenColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _label = label;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.opaque = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _label.frame = self.bounds;
}

@end

@interface OHCalendarHeatMapView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView* collectionView;
@property (strong, nonatomic) OHCalendarHeatMapLayout* layout;
@property (copy, nonatomic) NSDate* startDate;
@property (copy, nonatomic) NSDate* endDate;
@property (strong, nonatomic) NSCalendar* calendar;

@end

@implementation OHCalendarHeatMapView

#pragma mark init and UIView implementation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];

    NSDate* now = [NSDate date];
    NSDateComponents* components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    NSDate* today = [self.calendar dateFromComponents:components];
    
    self.endDate = today;
    
    NSDateComponents* aYearAgo = [[NSDateComponents alloc] init];
    aYearAgo.year = -1;
    self.startDate = [self.calendar dateByAddingComponents:aYearAgo toDate:self.endDate options:0];
    
    OHCalendarHeatMapLayout* layout = [[OHCalendarHeatMapLayout alloc] init];
    layout.startDate = self.startDate;
    layout.endDate = self.endDate;
    layout.calendar = self.calendar;
    
    self.layout = layout;
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                          collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [collectionView registerClass:[OHCalendarHeatMapDayCell class] forCellWithReuseIdentifier:@"day"];
    [collectionView registerClass:[OHCalendarHeatMapMonthView class] forSupplementaryViewOfKind:kOHCalendarHeatMapKindMonth withReuseIdentifier:@"month"];
    
    [self addSubview:collectionView];
    
    self.collectionView = collectionView;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

#pragma mark Public interface

- (void)setAllowsSelection:(BOOL)allowsSelection
{
    self.collectionView.allowsSelection = allowsSelection;
}

- (BOOL)allowsSelection
{
    return self.collectionView.allowsSelection;
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    self.collectionView.backgroundView = backgroundView;
}

- (UIView*)backgroundView
{
    return self.collectionView.backgroundView;
}

- (NSArray*)datesForSelectedItems
{
    return [NSArray array];
}

- (void)selectItemAtDate:(NSDate *)date animated:(BOOL)animated scrollPosition:(OHCalendarHeatMapViewScrollPosition)scrollPosition
{
    
}

- (void)deselectItemAtDate:(NSDate *)date animated:(BOOL)animated
{
    
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)scrollToItemAtDate:(NSDate *)date atScrollPosition:(OHCalendarHeatMapViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    NSIndexPath* indexPath = [self.layout indexPathForDate:date];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:animated];
}

#pragma mark UICollectionViewDataSource implementation

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSDateComponents* components = [self.calendar components:NSMonthCalendarUnit fromDate:self.startDate toDate:self.endDate options:0];
    NSInteger sections = components.month + 1;
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger sections = [self numberOfSectionsInCollectionView:self.collectionView];
    NSInteger numberOfItems = 0;
        
    if (section == sections - 1) {
        // month of the end date
        NSDateComponents* components = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:self.endDate];
        numberOfItems = components.day + 1;
        NSLog(@"Number of items for last month: %d", numberOfItems);
    } else {
        NSDateComponents* months = [[NSDateComponents alloc] init];
        months.month = section;
        NSDate* date = [self.calendar dateByAddingComponents:months toDate:self.startDate options:0];
        NSLog(@"Date: %@", date);
        NSRange days = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
        if (section == 0) {
            // month of the start date
            NSDateComponents* components = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                            fromDate:self.startDate];
            numberOfItems = days.length - components.day + 1;
            NSLog(@"Number of items for first month: %d", numberOfItems);
        } else {
            // somewhere in the middle
            numberOfItems = days.length;
            NSLog(@"Number of items for month %d: %d", section, numberOfItems);
        }
    }
    
    return numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OHCalendarHeatMapDayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"day" forIndexPath:indexPath];
    NSDate* date = [self.layout dateForIndexPath:indexPath];
    NSDateComponents* components = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSInteger day = components.day;
    cell.label.text = [NSString stringWithFormat:@"%d", day];
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    OHCalendarHeatMapMonthView* month = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"month" forIndexPath:indexPath];
    
    static NSDateFormatter* formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy MM"];
    }
    
    NSDate* date = [self.layout dateForIndexPath:indexPath];
    NSString* s = [formatter stringFromDate:date];
    month.label.text = s;
    return month;
    
}


#pragma mark UICollectionViewDelegate implementation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
