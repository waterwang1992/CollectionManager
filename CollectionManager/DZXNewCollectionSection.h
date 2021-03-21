//
//  DZCollectionSection.h
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DZXNewCollectionItem, DZXNewCollectionHeaderFooterViewItem;

NS_ASSUME_NONNULL_BEGIN

@interface DZXNewCollectionSection : NSObject

/// 分区类型
@property (nonatomic, readwrite, copy) NSString *sectionType;

/// 列数
@property (nonatomic, assign) NSInteger columnInSection;
/// 列间距，默认为0
@property (nonatomic, assign) CGFloat minimumLineSpacing;
/// 行间距，默认为0
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
/// 内边距，默认为 UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets insetForSection;

+ (instancetype)section;

@property (nonatomic, strong) __kindof DZXNewCollectionHeaderFooterViewItem *headerItem;

@property (nonatomic, strong) __kindof DZXNewCollectionHeaderFooterViewItem *footerItem;

@property (nonatomic, strong, readonly) NSMutableArray <__kindof DZXNewCollectionItem *> *cellItems;

- (void)addCellItem:(__kindof DZXNewCollectionItem *)cellItem;

- (void)addCellItems:(NSArray <__kindof DZXNewCollectionItem *> *)cellItems;

- (void)removeCellItem:(__kindof DZXNewCollectionItem *)cellItem;

- (void)removeAllItems;

- (void)insertCellItem:(__kindof DZXNewCollectionItem *)cellItem atIndex:(NSInteger)index;

- (void)replaceAllCellItems:(NSArray <DZXNewCollectionItem *> *)cellItems;

- (void)updateCellItemMainColor:(NSString *)colorString;

@end

NS_ASSUME_NONNULL_END
