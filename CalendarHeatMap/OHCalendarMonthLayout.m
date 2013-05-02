//
//  OHCalendarMonthLayout.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarMonthLayout.h"

@implementation OHCalendarMonthLayout

#pragma mark UICollectionViewLayout extension

- (void)prepareLayout
{
    NSLog(@"Prepare layout");
    
    CGRect bounds = self.collectionView.bounds;
    CGFloat cellsWidth = bounds.size.width - self.leftMargin - self.rightMargin;
    CGFloat w = floorf(cellsWidth/31);
    self.cellSize = CGSizeMake(w, w);
    
    NSDateComponents* components =
    [self.calendar components:NSMonthCalendarUnit
                     fromDate:self.startDateMidnight
                       toDate:self.endDateMidnight
                      options:0];
    NSInteger rows = components.month;
    CGFloat height = rows * self.cellSize.height;
    
    self.contentSize = CGSizeMake(bounds.size.width, MAX(bounds.size.height, height));
    
    NSLog(@"Layout prepared. Rows: %d, size: %@", rows, NSStringFromCGSize(self.contentSize));
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"layoutAttributesForElementsInRect:%@", NSStringFromCGRect(rect));

    NSMutableArray* attributes = [NSMutableArray array];
    NSInteger previousRows = (NSInteger)(rect.origin.y/self.cellSize.height);
    NSDateComponents* previousMonthsComponents = [[NSDateComponents alloc] init];
    previousMonthsComponents.month = previousRows;
    NSDate* date = [self.calendar dateByAddingComponents:previousMonthsComponents
                                                  toDate:self.startDateMonth
                                                 options:0];
    
    NSDateComponents* oneDayAfterComponents = [[NSDateComponents alloc] init];
    oneDayAfterComponents.day = 1;

    NSIndexPath* indexPath = [self indexPathForDate:date];
    CGFloat x = self.leftMargin;
    CGFloat y = previousRows * self.cellSize.height;
    
    while (y < rect.origin.y + rect.size.height) {
        
        NSInteger days = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section];
        for (NSInteger c = 0; c < days; c++) {
            CGRect frame = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
            indexPath = [self indexPathForDate:date];
            
            if ([date timeIntervalSinceDate:self.startDateMidnight] >= 0 &&
                [date timeIntervalSinceDate:self.endDateMidnight] <= 0) {
                UICollectionViewLayoutAttributes* attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attr.frame = frame;
                attr.zIndex = 1;
                [attributes addObject:attr];
            }
            
            date = [self.calendar dateByAddingComponents:oneDayAfterComponents toDate:date options:0];
            x += self.cellSize.width;

        }
        
        x = self.leftMargin;
        y += self.cellSize.height;
    }

    NSLog(@"Created %d attributes", attributes.count);
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
    NSDateComponents* components = [self.calendar components:NSMonthCalendarUnit fromDate:self.startDateMonth toDate:date options:0];
    
    NSInteger rows = components.month;
    
    NSRange days = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    NSInteger columns = days.length;
    
    CGRect rect = CGRectMake(columns * self.cellSize.width, rows * self.cellSize.height, self.cellSize.width, self.cellSize.height);
    
    return rect;
    
}

@end
