//
//  UserGridCell.h
//  Evently
//
//  Created by Ning Liang on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserGridCell : UITableViewCell <UICollectionViewDataSource>

@property (nonatomic, strong) NSString *gridTitle;
@property (nonatomic, strong) NSArray *userFacebookIds;

@end
