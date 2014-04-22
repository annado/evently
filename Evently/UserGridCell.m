//
//  UserGridCell.m
//  Evently
//
//  Created by Ning Liang on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UserGridCell.h"
#import "UserImageCollectionViewCell.h"

@interface UserGridCell ()

@property (weak, nonatomic) IBOutlet UILabel *gridTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *imageGrid;

@end

@implementation UserGridCell

- (void)awakeFromNib
{
    // Initialization code
    [self.imageGrid registerNib:[UINib nibWithNibName:@"UserImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserImageCollectionViewCell"];
    self.imageGrid.dataSource = self;
    self.imageGrid.delegate = self;
    
    self.imageGrid.backgroundColor = [UIColor whiteColor];
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
    return self.userFacebookIds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserImageCollectionViewCell *cell = [self.imageGrid dequeueReusableCellWithReuseIdentifier:@"UserImageCollectionViewCell" forIndexPath:indexPath];
    cell.userImageURL = [User avatarURL:self.userFacebookIds[indexPath.row][@"facebookID"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50, 50);
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    
//}



@end
