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
    // Tell the collection view to reloadData
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userFacebookIds.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserImageCollectionViewCell *cell = [self.imageGrid dequeueReusableCellWithReuseIdentifier:@"UserImageCollectionViewCell" forIndexPath:indexPath];
    cell.userImageURL = [User avatarURL:self.userFacebookIds[indexPath.row][@"facebookID"]];
    return cell;
}

@end
