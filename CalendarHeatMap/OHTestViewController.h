//
//  OHTestViewController.h
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-14.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OHTestViewControllerLayout : UICollectionViewFlowLayout

@end

@interface OHTestViewControllerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@interface OHTestViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
