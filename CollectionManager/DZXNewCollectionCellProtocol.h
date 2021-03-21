//
//  DZCollectionCellProtocol.h
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DZXNewCollectionItem;

NS_ASSUME_NONNULL_BEGIN

@protocol DZXNewCollectionCellProtocol <NSObject>

- (void)configCellItem:(__kindof DZXNewCollectionItem *)cellItem;

@optional
- (void)configWillDisplayCellItem:(__kindof DZXNewCollectionItem *)cellItem;

- (void)configEndDisplayCellItem:(__kindof DZXNewCollectionItem *)cellItem;

@end

NS_ASSUME_NONNULL_END
