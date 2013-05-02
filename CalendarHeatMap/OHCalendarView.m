//
//  OHCalendarView.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-21.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarView.h"

static NSString* const OHCalendarViewDefaultDayCellIdentifier = @"OHCalendarViewDefaultDayCell";
static NSString* const OHCalendarViewDefaultMonthViewIdentifier = @"OHCalendarViewDefaultMonthViewIdentifier";


@interface OHCalendarViewDefaultDayCell : UICollectionViewCell

@property (nonatomic, weak, readonly) UILabel* label;

@end

@implementation OHCalendarViewDefaultDayCell

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
    self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label];
    _label = label;
}

@end

@interface OHCalendarViewDefaultMonthView : UICollectionReusableView

@property (nonatomic, copy) UIBezierPath* path;
@property (nonatomic, copy) UIColor* fillColor;
@property (nonatomic, copy) UIColor* strokeColor;


@end

@implementation OHCalendarViewDefaultMonthView

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
    self.opaque = NO;
    self.clipsToBounds = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.path = nil;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if ([layoutAttributes isKindOfClass:[OHCalendarViewLayoutAttributes class]]) {
        OHCalendarViewLayoutAttributes* calendarAttributes = (OHCalendarViewLayoutAttributes*)layoutAttributes;
        self.path = calendarAttributes.boundsPath;
        [self setNeedsDisplay];
    }
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = [fillColor copy];
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = [strokeColor copy];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (!self.path) {
        return;
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    CGContextSetFillColorWithColor(c, self.fillColor.CGColor);
    [self.path fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
    
    CGContextSetLineWidth(c, 4);
    CGContextSetStrokeColorWithColor(c, self.strokeColor.CGColor);
    //CGContextStrokeRect(c, rect);
    self.path.lineWidth = 2.0;
    [self.path stroke];
}

@end

@interface OHCalendarView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UICollectionView* collectionView;

@end

@implementation OHCalendarView

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame calendarLayout:(OHCalendarLayout*)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        self.calendarLayout = layout;
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
    
    if (!self.calendarLayout) {
        self.calendarLayout = [[OHCalendarWeekLayout alloc] init];
    }
        
    UICollectionView* collectionView =
    [[UICollectionView alloc] initWithFrame:self.bounds
                       collectionViewLayout:self.calendarLayout];
    
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [collectionView registerClass:[OHCalendarViewDefaultDayCell class]
       forCellWithReuseIdentifier:OHCalendarViewDefaultDayCellIdentifier];
    [collectionView registerClass:[OHCalendarViewDefaultMonthView class]
       forSupplementaryViewOfKind:OHCalendarLayoutSupplementaryKindMonthView
              withReuseIdentifier:OHCalendarViewDefaultMonthViewIdentifier];
    
    [self addSubview:collectionView];
    
    self.collectionView = collectionView;
}

#pragma mark - Public interface

- (void)setShowDayLabel:(BOOL)showDayLabel
{
    _showDayLabel = showDayLabel;
    [self reloadData];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
}

- (NSDate*)startDate
{
    return self.calendarLayout.startDate;
}

- (void)setStartDate:(NSDate *)startDate
{
    self.calendarLayout.startDate = startDate;
}

- (NSDate*)endDate
{
    return self.calendarLayout.endDate;
}

- (void)setEndDate:(NSDate *)endDate
{
    self.calendarLayout.endDate = endDate;
}

- (NSCalendar*)calendar
{
    return self.calendarLayout.calendar;
}

- (void)setCalendar:(NSCalendar *)calendar
{
    self.calendarLayout.calendar = calendar;
}

- (NSArray*)datesForSelectedItems
{
    NSLog(@"Not yet implemented");
    abort();
}
- (void)selectItemAtDate:(NSDate *)date animated:(BOOL)animated scrollPosition:(OHCalendarViewScrollPosition)scrollPosition
{
    NSLog(@"Not yet implemented");
    abort();
}

- (void)deselectItemAtDate:(NSDate *)date animated:(BOOL)animated
{
    NSLog(@"Not yet implemented");
    abort();
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)scrollToItemAtDate:(NSDate *)date atScrollPosition:(OHCalendarViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    NSIndexPath* indexPath = [self.calendarLayout indexPathForDate:date];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:(UICollectionViewScrollPosition)scrollPosition
                                        animated:animated];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
}

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forDate:(NSDate*)date
{
    NSIndexPath* indexPath = [self.calendarLayout indexPathForDate:date];
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                          forIndexPath:indexPath];
}

- (id)dequeueReusableSupplementaryViewOfKind:(NSString*)elementKind withReuseIdentifier:(NSString *)identifier forDate:(NSDate*)date
{
    NSIndexPath* indexPath = [self.calendarLayout indexPathForDate:date];
    return [self.collectionView dequeueReusableSupplementaryViewOfKind:elementKind
                                                   withReuseIdentifier:identifier
                                                          forIndexPath:indexPath];
}

- (void)setCalendarViewLayout:(OHCalendarLayout*)layout animated:(BOOL)animated
{
    //TODO: clear out who is responsible for owing the time span. this view or the layout
    layout.startDate = self.startDate;
    layout.endDate = self.endDate;
    layout.calendar = self.calendar;    
    self.calendarLayout = layout;
    [self.collectionView setCollectionViewLayout:layout animated:animated];
}

#pragma mark - UICollectionViewDataSource implementation


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // TODO: cache the number of sections when setting calendar and start/end dates
    NSDateComponents* components = [self.calendar components:NSMonthCalendarUnit
                                                    fromDate:self.startDate
                                                      toDate:self.endDate
                                                     options:0];
    NSInteger sections = components.month + 1;
    return sections;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger sections = [self numberOfSectionsInCollectionView:collectionView];
    NSInteger numberOfItems = 0;
    if (sections == sections - 1) {
        // month of the end date
        NSDateComponents* components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                        fromDate:self.endDate];
        numberOfItems = components.day + 1;
    } else {
        NSDateComponents* monthComponents = [[NSDateComponents alloc] init];
        monthComponents.month = section;
        NSDate* date = [self.calendar dateByAddingComponents:monthComponents
                                                      toDate:self.startDate
                                                     options:0];
        NSRange days = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                           inUnit:NSMonthCalendarUnit
                                          forDate:date];
        if (section == 0) {
            // month of the start date
            NSDateComponents* components = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                            fromDate:self.startDate];
            numberOfItems = days.length - components.day + 1;
        } else {
            // somewhere in the middle
            numberOfItems = days.length;
        }
    }
    
    return numberOfItems;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate* date = [self.calendarLayout dateForIndexPath:indexPath];
    UICollectionViewCell* cell = nil;
    if ([self.dataSource respondsToSelector:@selector(calendarView:cellForDate:)]) {
        cell = [self.dataSource calendarView:self cellForDate:date];
    }
    if (!cell) {
        OHCalendarViewDefaultDayCell* defaultCell = [collectionView dequeueReusableCellWithReuseIdentifier:OHCalendarViewDefaultDayCellIdentifier forIndexPath:indexPath];
        
        UIColor* backgroundColor = nil;
        if ([self.dataSource respondsToSelector:@selector(calendarView:backgroundColorForDate:)]) {
            backgroundColor = [self.dataSource calendarView:self backgroundColorForDate:date];
        }

        if (!backgroundColor) {
            backgroundColor = [UIColor whiteColor];
        }
        defaultCell.backgroundColor = backgroundColor;

        if (self.showDayLabel) {
            NSString* labelText = nil;
            if ([self.dataSource respondsToSelector:@selector(calendarView:labelForDate:)]) {
                labelText = [self.dataSource calendarView:self labelForDate:date];
            }
            if (!labelText) {
                NSDateComponents* components = [self.calendar components:NSDayCalendarUnit fromDate:date];
                NSInteger day = components.day;
                labelText = [NSString stringWithFormat:@"%d", day];
            }
            defaultCell.label.text = labelText;
            defaultCell.label.hidden = NO;
        } else {
            defaultCell.label.hidden = YES;
        }
        cell = defaultCell;
    }
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    OHCalendarViewDefaultMonthView* monthView = [collectionView dequeueReusableSupplementaryViewOfKind:OHCalendarLayoutSupplementaryKindMonthView
                                                                                  withReuseIdentifier:OHCalendarViewDefaultMonthViewIdentifier
                                                                                         forIndexPath:indexPath];
    if (indexPath.section % 2 == 0) {
        monthView.fillColor = [UIColor redColor];
        monthView.strokeColor = [UIColor blueColor];
    } else {
        monthView.fillColor = [UIColor clearColor];
        monthView.strokeColor = [UIColor clearColor];
    }
    return monthView;
}

#pragma mark UICollectionViewDelegate implementation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectItemAtDate:)]) {
        NSDate* date = [self.calendarLayout dateForIndexPath:indexPath];
        [self.delegate calendarView:self didSelectItemAtDate:date];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(calendarView:didDeselectItemAtDate:)]) {
        NSDate* date = [self.calendarLayout dateForIndexPath:indexPath];
        [self.delegate calendarView:self didDeselectItemAtDate:date];
    }
}

@end
