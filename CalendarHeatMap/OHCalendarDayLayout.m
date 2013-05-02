//
//  OHCalendarDayLayout.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarDayLayout.h"

@implementation OHCalendarDayLayout

#pragma mark UICollectionViewLayout extension

- (void)prepareLayout
{
    NSLog(@"Prepare layout");

    CGRect bounds = self.collectionView.bounds;
    CGFloat cellsWidth = bounds.size.width - self.leftMargin - self.rightMargin;
    self.cellSize = CGSizeMake(cellsWidth, cellsWidth);
    
    NSDateComponents* components =
    [self.calendar components:NSDayCalendarUnit
                     fromDate:self.startDateMidnight
                       toDate:self.endDate
                      options:0];
    
    NSInteger rows = components.day;
    CGFloat height = rows * self.cellSize.height;
    
    self.contentSize = CGSizeMake(bounds.size.width, MAX(bounds.size.height, height));
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    NSInteger previousRows = (NSInteger)(rect.origin.y/self.cellSize.height);
    NSDateComponents* previousDaysComponents = [[NSDateComponents alloc] init];
    previousDaysComponents.day = previousRows;
    NSDate* date = [self.calendar dateByAddingComponents:previousDaysComponents
                                                  toDate:self.startDateMidnight
                                                 options:0];
    
    NSDateComponents* oneDayAfterComponents = [[NSDateComponents alloc] init];
    oneDayAfterComponents.day = 1;

    NSIndexPath* indexPath = nil;
    CGFloat y = previousRows * self.cellSize.height;
    
    while (y < rect.origin.y + rect.size.height) {
        CGRect frame = CGRectMake(self.leftMargin, y, self.cellSize.width, self.cellSize.height);
        
        indexPath = [self indexPathForDate:date];
        
        UICollectionViewLayoutAttributes* attr =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attr.frame = frame;
        attr.zIndex = 1;
        [attributes addObject:attr];
        
        y += self.cellSize.height;
        date = [self.calendar dateByAddingComponents:oneDayAfterComponents
                                              toDate:date
                                             options:0];
        if ([date timeIntervalSinceDate:self.endDateMidnight] > 0) {
            break;
        }
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
    return nil;
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

#pragma mark - OHCalenderLayout subclassing

- (CGRect)rectForDate:(NSDate*)date
{
    static const NSTimeInterval secondsInDay = 60.0 * 60.0 * 24.0;
    
    NSTimeInterval interval = [date timeIntervalSinceDate:self.startDateMidnight];
    NSInteger row = interval / secondsInDay;
    
    CGFloat x = self.leftMargin;
    CGFloat y = row * self.cellSize.height;
    
    CGRect rect = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
    
//    NSLog(@"rectForDate:%@ = %@ (row=%d)",
//          date, NSStringFromCGRect(rect), row);
    
    return rect;
}

@end
