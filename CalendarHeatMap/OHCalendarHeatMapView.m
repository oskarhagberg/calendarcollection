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

@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* adjustedStartDate;
@property (nonatomic, copy) NSDate* endDate;
@property (nonatomic, strong) NSCalendar* calendar;

@property (nonatomic) CGSize contentSize;

@end

@implementation OHCalendarHeatMapLayout

- (void)prepareLayout
{
    
    NSDateComponents* weekdayComponents = [self.calendar components:NSWeekdayCalendarUnit fromDate:self.startDate];
    if (weekdayComponents.weekday == 1) {
        self.adjustedStartDate = self.startDate;
    } else {
        NSDateComponents* adjustment = [[NSDateComponents alloc] init];
        adjustment.day = 1 - weekdayComponents.weekday;
        self.adjustedStartDate = [self.calendar dateByAddingComponents:adjustment toDate:self.startDate options:0];
    }
    
    NSDateComponents* components = [self.calendar components:NSWeekCalendarUnit
                                                    fromDate:self.adjustedStartDate
                                                      toDate:self.endDate options:0];
    NSInteger rows = components.week;
    CGFloat height = rows * 40.0;
    self.contentSize = CGSizeMake(self.collectionView.bounds.size.width, height);
}

- (NSDate*)dateForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger year = indexPath.section / 12;
    NSInteger month = indexPath.section % 12;
    NSInteger day = indexPath.item;
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    NSDate* date = [self.calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
    return date;
}

- (NSIndexPath*)indexPathForDate:(NSDate*)date
{
    NSUInteger units = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* components = [self.calendar components:units fromDate:self.startDate toDate:date options:0];
    return [NSIndexPath indexPathForItem:components.day inSection:components.month];
}

- (CGRect)rectForDate:(NSDate*)date
{
    static const NSTimeInterval secondsInDay = 60.0 * 60.0 * 24.0;
    static const NSTimeInterval secondsInWeek = secondsInDay * 7.0;
    
    NSTimeInterval interval = [date timeIntervalSinceDate:self.adjustedStartDate];
    
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
    NSInteger row = rect.origin.y / 40.0;
    NSInteger column = rect.origin.x / 40.0;
    
    NSInteger rows = rect.size.height / 40.0 + 1;
    NSInteger columns = rect.size.width / 40.0 + 1;
    columns = MIN(7, columns);
    
    NSDateComponents* weeks = [[NSDateComponents alloc] init];
    weeks.week = row;
    NSDate* rectStartDate = [self.calendar dateByAddingComponents:weeks toDate:self.startDate options:0];
    
    CGRect firstFrame = [self rectForDate:rectStartDate];
    NSInteger startColumn = firstFrame.origin.x / 40.0;
    
    NSMutableArray* attributes = [NSMutableArray array];
    
    NSDateComponents* dayOffsetComponents = [[NSDateComponents alloc] init];
    dayOffsetComponents.day = 0;
    CGRect frame = firstFrame;
    for (NSInteger r = 0; r<rows; r++) {

        for (NSInteger c = column; c<columns; c++) {
            
            if (r == 0 && c < startColumn) {
                continue;
            }
            
            NSDate* date = [self.calendar dateByAddingComponents:dayOffsetComponents toDate:rectStartDate options:0];
            NSIndexPath* indexPath = [self indexPathForDate:date];
            
            UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = frame;
            attr.zIndex = 1;
            
            [attributes addObject:attr];
            
            //NSLog(@"Attr: [%f,%f,%f,%f] => [%d,%d]", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height, indexPath.section, indexPath.row);
            
            dayOffsetComponents.day++;
            frame = CGRectOffset(frame, 40.0, 0.0);
            
            NSComparisonResult cr = [date compare:self.endDate];
            if (cr == NSOrderedSame || cr == NSOrderedDescending) {
                r = rows;
                break;
            }

        }
        
        frame = CGRectMake(0.0, frame.origin.y + 40.0, frame.size.width, frame.size.height);

    }
    
    return attributes;
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
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
    [self addSubview:label];
    _label = label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _label.frame = self.bounds;
}

@end

@interface OHCalendarHeatMapMonthView : UICollectionReusableView

@end

@implementation OHCalendarHeatMapMonthView

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
    [collectionView registerClass:[OHCalendarHeatMapMonthView class] forCellWithReuseIdentifier:@"month"];
    
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
    NSInteger sections = components.month + components.year * 12;
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    NSDateComponents* months = [[NSDateComponents alloc] init];
    months.month = section;
    NSDate* date = [self.calendar dateByAddingComponents:months toDate:self.startDate options:0];
    NSRange days = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    NSInteger numberOfItems = days.length;
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


#pragma mark UICollectionViewDelegate implementation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
