//
//  OHTestViewController.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHTestViewController.h"

@implementation OHTestViewControllerLayout

- (void)prepareLayout
{
    NSLog(@"prepareLayout");
    [super prepareLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"layoutAttributesForElementsInRect:[%f,%f,%f,%f]", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    return [super layoutAttributesForElementsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"layoutAttributesForItemAtIndexPath: [%d,%d]", indexPath.section, indexPath.item);
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}


@end

@implementation OHTestViewControllerCell

@end

@interface OHTestViewController ()

@end

@implementation OHTestViewController

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
    OHTestViewControllerLayout* layout = (OHTestViewControllerLayout*)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(200.0, 70.0);
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource implementation

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 100;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1000;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OHTestViewControllerCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"[%d,%d]", indexPath.section, indexPath.item];
    cell.backgroundColor = [UIColor whiteColor];
    cell.label.textColor = [UIColor blackColor];
    return cell;
}

@end
