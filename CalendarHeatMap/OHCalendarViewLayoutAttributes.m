//
//  OHCalendarViewLayoutAttributes.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-21.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarViewLayoutAttributes.h"

@implementation OHCalendarViewLayoutAttributes

-(id)copyWithZone:(NSZone *)zone
{
    id copy = [super copyWithZone:zone];
    [copy setBoundsPath:self.boundsPath];
    return copy;
}

@end
