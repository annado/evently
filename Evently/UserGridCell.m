//
//  UserGridCell.m
//  Evently
//
//  Created by Ning Liang on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UserGridCell.h"
#import "UserImageCollectionViewCell.h"

// TODO configurable?
NSInteger kMaximumItems = 25;

@interface UserGridCell ()

@property (weak, nonatomic) IBOutlet UILabel *gridTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *imageGrid;

@end

// Only displays at most the max number of items
@implementation UserGridCell

- (void)awakeFromNib
{
    // Initialization code
    [self.imageGrid registerNib:[UINib nibWithNibName:@"UserImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserImageCollectionViewCell"];
    self.imageGrid.dataSource = self;
    self.imageGrid.delegate = self;
    self.imageGrid.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumLineSpacing = 7.0;
    layout.minimumInteritemSpacing = 7.0;
    layout.itemSize = CGSizeMake(50, 50);

    self.imageGrid.collectionViewLayout = layout;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGridTitle:(NSString *)gridTitle {
    _gridTitle = gridTitle;
    self.gridTitleLabel.text = _gridTitle;
}

- (void)setUserFacebookIds:(NSArray *)userFacebookIds {
    _userFacebookIds = userFacebookIds;
    [self.imageGrid reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.userFacebookIds.count, kMaximumItems);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserImageCollectionViewCell *cell = [self.imageGrid dequeueReusableCellWithReuseIdentifier:@"UserImageCollectionViewCell" forIndexPath:indexPath];
    cell.userImageURL = [User avatarURL:self.userFacebookIds[indexPath.row][@"facebookID"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50, 50);
}

+ (CGFloat)heightForNumberOfItems:(NSInteger)numItems {
    if (numItems == 0) {
        return 0.0;
    } else {
        numItems = MIN(numItems, kMaximumItems);
        NSInteger numRows = ceil((CGFloat)numItems / 5.0);
        return 80 + numRows * 50 + (numRows - 1) * 7;
    }
}

@end
