//
//  DZCollectionHeaderFooterProtocol.h
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DZXNewCollectionHeaderFooterViewItem;

NS_ASSUME_NONNULL_BEGIN

@protocol DZXNewCollectionHeaderFooterProtocol <NSObject>

- (void)configHeaderFooterViewItem:(__kindof DZXNewCollectionHeaderFooterViewItem *)viewItem;

@end

NS_ASSUME_NONNULL_END
