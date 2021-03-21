//
//  DZCollectionItem.h
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZXNewCollectionItem : NSObject

/// 对应的cell class, 默认为UICollectionViewCell
@property (nonatomic, readwrite, strong) Class cellClass;

/// 对应identifier , 可不传 默认为类名
@property (nonatomic, readwrite, copy) NSString *cellIdentifier;

/// item的类型
@property (nonatomic, readwrite, copy) NSString *itemType;

/// 是否要动态实时计算高度
/// @note 默认为NO
/// @attention 如果改值为yes, 则每次reloadcell 时都会用重新生成cell视图, 并调用系统方法 尝试获得cell的压缩高度, 比较浪费性能, 请慎用.
@property (nonatomic, readwrite, assign) BOOL dynamicHeight;

// 高度
@property (nonatomic, assign) CGFloat height;
// 宽度
@property (nonatomic, assign) CGFloat width;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL hiddenRow;

@property (nonatomic, copy) void(^didSelectRow)(__kindof DZXNewCollectionItem *cellItem,NSIndexPath *indexPath);

@property (nonatomic, copy) void(^willDisplay)( __kindof UICollectionViewCell *cell,  DZXNewCollectionItem *cellItem, NSIndexPath *indexPath);

@property (nonatomic, copy) void(^didEndDisplay)( __kindof UICollectionViewCell *cell,  DZXNewCollectionItem *cellItem, NSIndexPath *indexPath);

/// 卡片化主题色
@property (nonatomic, copy)   NSString *mainColor;

@end

