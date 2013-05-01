//
//  OHCalendarWeekLayout.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarWeekLayout.h"

NSString* const OHCalendarWeekLayoutMonthView = @"OHCalendarWeekLayoutMonthView";

@implementation OHCalendarWeekLayout

+ (Class)layoutAttributesClass
{
    return [OHCalendarViewLayoutAttributes class];
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

#pragma mark UICollectionViewLayout extension

- (void)prepareLayout
{
    NSLog(@"Prepare layout");
    
    CGRect bounds = self.collectionView.bounds;
    CGFloat cellsWidth = bounds.size.width - self.leftMargin - self.rightMargin;
    CGFloat w = floorf(cellsWidth/7);
    self.cellSize = CGSizeMake(w, w);
    
    NSDateComponents* components =
    [self.calendar components:NSWeekCalendarUnit
                     fromDate:self.startDateWeek
                       toDate:self.endDateMidnight
                      options:0];
    
    NSInteger rows = components.week + 1;
    CGFloat height = rows * self.cellSize.height;
    
    //If content width is not bounds width, layoutAttributesForElementsInRect will be called for each pixel scroll
    self.contentSize = CGSizeMake(self.collectionView.bounds.size.width, height);

    NSLog(@"Layout prepared. Rows: %d, size: %@", rows, NSStringFromCGSize(self.contentSize));
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"layoutAttributesForElementsInRect:%@", NSStringFromCGRect(rect));
    
    NSMutableArray* attributes = [NSMutableArray array];
    
    //Find the first day of the month that begins the rect (or the start date if thats later)
    NSInteger previousRows = (NSInteger)(rect.origin.y/self.cellSize.height);
    NSDateComponents* previousWeeksComponents = [[NSDateComponents alloc] init];
    previousWeeksComponents.week = previousRows;
    NSDate* date = [self.calendar dateByAddingComponents:previousWeeksComponents
                                                  toDate:self.startDateWeek
                                                 options:0];
    date = [[self.calendar dateFromComponents:[self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit
                                                                                  fromDate:date]]
            laterDate:self.startDateMidnight];
    CGRect monthStartDayRect = [self rectForDate:date];
    
    // Find the first day of the week of the date.
    NSDateComponents* weekdayComponents = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    if (weekdayComponents.weekday != 1) {
        NSDateComponents* adjustment = [[NSDateComponents alloc] init];
        adjustment.day = 1 - weekdayComponents.weekday;
        date = [self.calendar dateByAddingComponents:adjustment toDate:date options:0];
    }
    
    NSDateComponents* oneDayAfterComponents = [[NSDateComponents alloc] init];
    oneDayAfterComponents.day = 1;
    
    NSIndexPath* indexPath = nil;
    UIBezierPath* path = nil;
    CGFloat x = self.leftMargin;
    CGFloat y = monthStartDayRect.origin.y;
    CGPoint monthStartPoint = CGPointMake(self.leftMargin, y);

    BOOL fillingRect = YES;
    BOOL fillingMonth = YES;
    while (fillingRect || fillingMonth) {
        
        for (NSInteger column = 0; column < 7; column ++) {
            
            CGRect frame = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
            
            if ([date timeIntervalSinceDate:self.startDateMidnight] >= 0 &&
                [date timeIntervalSinceDate:self.endDateMidnight] <= 0) {
                
                indexPath = [self indexPathForDate:date];
                
                // Since we loop over more days than necessary in order to build up
                // a complete month, we need to check if the cell is actually
                // in the layout rect
                if (CGRectIntersectsRect(frame, rect)) {
                    UICollectionViewLayoutAttributes* attr =
                    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                    attr.frame = frame;
                    attr.zIndex = 1;
                    [attributes addObject:attr];
                }
                
                if (indexPath.item == 0) {
                    
                    if (path) {
                        NSLog(@"Adding month for section %d {{%f, %f}, {%f, %f}}", indexPath.section -1, monthStartPoint.x, monthStartPoint.y, path.bounds.size.width, path.bounds.size.height);
                        // Close previous month
                        [attributes addObject:[self monthAttributesWithIndexPath:indexPath
                                                                      beizerPath:path
                                                                      startPoint:monthStartPoint]];
                        if (fillingRect == NO) {
                            NSLog(@"stopping because month is done and rect is filled");
                            fillingMonth = NO; // This will end the loop
                        }
                    }
                    
                    // Begin a new month path
                    monthStartPoint = CGPointMake(self.leftMargin, y);
                    path = [[UIBezierPath alloc] init];
                }
                
                // Append day cell rect to month bounds path
                CGRect translatedFrame = CGRectMake(frame.origin.x - monthStartPoint.x, frame.origin.y - monthStartPoint.y, frame.size.width, frame.size.height);
                [path appendPath:[UIBezierPath bezierPathWithRect:translatedFrame]];
                NSLog(@"Appending rect for [%d, %d]: %@", indexPath.section, indexPath.item, NSStringFromCGRect(translatedFrame));
                
            } else if ([date timeIntervalSinceDate:self.endDateMidnight] > 0) {
                NSLog(@"Adding month for indexPath %@ bounds %@", indexPath, NSStringFromCGRect(path.bounds));
                NSLog(@"Stopping because past end date");
                // Ran out of days before pixels
                fillingRect = NO;
                fillingMonth = NO; // This will end the lop
                // Add the ongoing month path
                [attributes addObject:[self monthAttributesWithIndexPath:indexPath
                                                              beizerPath:path
                                                              startPoint:monthStartPoint]];
            }
            
            date = [self.calendar dateByAddingComponents:oneDayAfterComponents
                                                  toDate:date
                                                 options:0];
            x += self.cellSize.width;
        }
        
        x = self.leftMargin;
        y += self.cellSize.height;
        
        if (y>rect.origin.y + rect.size.height) {
            NSLog(@"Rect is filled x: %f y: %f", x, y);
            fillingRect = NO;
        }
    }
    
    return attributes;
}

- (OHCalendarViewLayoutAttributes*)monthAttributesWithIndexPath:(NSIndexPath*)indexPath beizerPath:(UIBezierPath*)path startPoint:(CGPoint)point
{
    CGRect pathBounds = path.bounds;
    OHCalendarViewLayoutAttributes* month =
    [OHCalendarViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:OHCalendarWeekLayoutMonthView withIndexPath:indexPath];
    month.zIndex = 2;
    month.frame = CGRectMake(point.x, point.y, pathBounds.size.width, pathBounds.size.height);
    month.boundsPath = path;
    return month;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
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
    UICollectionViewLayoutAttributes* attr = nil;
    if ([OHCalendarWeekLayoutMonthView isEqualToString:kind]) {
        NSDate* date = [self dateForIndexPath:indexPath];
        CGRect rect = [self rectForDate:date];
        NSArray* attributes = [self layoutAttributesForElementsInRect:rect];
        for (UICollectionViewLayoutAttributes* a in attributes) {
            if ([a.representedElementKind isEqualToString:OHCalendarWeekLayoutMonthView]) {
                attr = a;
                break;
            }
        }
    }
    return attr;
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

#pragma mark - OHCalenderLayout subclassing

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

#pragma mark - Private

- (CGRect)rectForDate:(NSDate*)date
{
    static const NSTimeInterval secondsInDay = 60.0 * 60.0 * 24.0;
    static const NSTimeInterval secondsInWeek = secondsInDay * 7.0;
    
    NSTimeInterval interval = [date timeIntervalSinceDate:self.startDateWeek];
    NSInteger row = interval / secondsInWeek;
    NSInteger column = (interval - row * secondsInWeek) / secondsInDay;
    
    CGFloat x = column * self.cellSize.height;
    CGFloat y = row * self.cellSize.width;
    
    CGRect rect = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
    
    NSLog(@"rectForDate:%@ = %@ (row=%d, col=%d)",
          date, NSStringFromCGRect(rect), row, column);
    
    return rect;
}

@end
