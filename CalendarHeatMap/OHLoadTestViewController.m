//
//  OHLoadTestViewController.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-05-02.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHLoadTestViewController.h"

@interface OHLoadTestViewController ()

@end

@implementation OHLoadTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1000;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [self randomHSBColor];
    return cell;
}

#define rr(min, max) ((float)rand()/RAND_MAX * (max-min)+min)


- (UIColor*)randomHSBColor
{
    double h = rr(0.2, 0.2);
    double s = rr(0.0, 0.4);
    double b = rr(0.8, 1.0);
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:1.0];
}

@end
