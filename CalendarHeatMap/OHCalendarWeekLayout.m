//
//  OHCalendarWeekLayout.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarWeekLayout.h"

@implementation OHCalendarWeekLayout

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
    NSInteger sections = [self.collectionView.dataSource
                          numberOfSectionsInCollectionView:self.collectionView];
    
    NSInteger previousRows = (NSInteger)(rect.origin.y/self.cellSize.height);
    NSDateComponents* previousWeeksComponents = [[NSDateComponents alloc] init];
    previousWeeksComponents.week = previousRows;
    
    NSDateComponents* oneDayAfterComponents = [[NSDateComponents alloc] init];
    oneDayAfterComponents.day = 1;
    
    NSDate* date = [self.calendar dateByAddingComponents:previousWeeksComponents
                                                  toDate:self.startDateWeek
                                                 options:0];
    
    CGFloat x = self.leftMargin;
    CGFloat y = previousRows * self.cellSize.height;
    
    BOOL running = YES;
    while (running) {
        for (NSInteger column = 0; column < 7; column ++) {
            CGRect frame = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
            
            if ([date timeIntervalSinceDate:self.startDateMidnight] >= 0 &&
                [date timeIntervalSinceDate:self.endDateMidnight] <= 0) {
                
                NSIndexPath* indexPath = [self indexPathForDate:date];
                UICollectionViewLayoutAttributes* attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attr.frame = frame;
                attr.zIndex = 1;
                // Since we loop over more days than necessary in order to build up
                // a complete month, we need to check if the cell is actually
                // in the layout rect
                if (CGRectIntersectsRect(frame, rect)) {
                    [attributes addObject:attr];
                }
                
            } else {
                if ([date timeIntervalSinceDate:self.endDateMidnight] > 0) {
                    running = NO;
                }
            }
            
            date = [self.calendar dateByAddingComponents:oneDayAfterComponents
                                                  toDate:date
                                                 options:0];
            x += self.cellSize.width;
        }
        
        x = self.leftMargin;
        y += self.cellSize.height;
    }
    
    return attributes;
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
    NSLog(@"Not yet implemented");
    abort();
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Not yet implemented");
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
    
    CGFloat x = row * self.cellSize.height;
    CGFloat y = column * self.cellSize.width;
    
    CGRect rect = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
    
    NSLog(@"rectForDate:%@ = %@ (row=%d, col=%d)",
          date, NSStringFromCGRect(rect), row, column);
    
    return rect;
}

@end
