//
//  DZCollectionHeaderFooterViewItem.h
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DZXNewCollectionHeaderFooterViewItem;

NS_ASSUME_NONNULL_BEGIN

@interface DZXNewCollectionHeaderFooterViewItem : NSObject

/// 对应的class, 默认为 UICollectionReusableView
@property (nonatomic, readwrite, strong) Class headerFooterClass;

/// 对应的identifier,可不传 默认为类名
@property (nonatomic, readwrite, copy) NSString *headerFooterIdentifier;

/// 是否隐藏
@property (nonatomic, assign) BOOL hidden;

/// 高度
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, copy) void(^willDisplay)( __kindof UICollectionReusableView *view,  __kindof DZXNewCollectionHeaderFooterViewItem *headerViewItem, NSInteger section);

@property (nonatomic, copy) void(^didEndDisplay)( __kindof UICollectionReusableView *view,  __kindof DZXNewCollectionHeaderFooterViewItem *headerViewItem, NSInteger section);

@end

NS_ASSUME_NONNULL_END
