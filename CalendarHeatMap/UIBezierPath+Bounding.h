//
//  UIBezierPath+Bounding.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-05-01.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIBezierPath (Bounding)

@property (nonatomic, readonly) UIBezierPath *convexHull;
@property (nonatomic, readonly) NSArray *sortedPoints;

@end
