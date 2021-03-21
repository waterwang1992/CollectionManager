//
//  DZCollectionManager.h
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZCollectionViewWaterfallFlowLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class DZXNewCollectionItem;
@protocol DZXNewCollectionManagerDelegate <NSObject, UITableViewDelegate>

@optional

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath cellItem:(DZXNewCollectionItem *)item;

#pragma mark - scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;

@end

@class UICollectionView, DZXNewCollectionSection, DZXNewCollectionItem;

@interface DZXNewCollectionManager : NSObject <DZCollectionViewWaterfallFlowLayoutDataSource>


@property (nonatomic, weak, nullable) id <DZXNewCollectionManagerDelegate> delegate;

+ (instancetype)managerWithCollectionView:(UICollectionView *)collectionView;
// waterFlow是否使用伪瀑布流
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView collectionViewLayout:(UICollectionViewLayout *_Nullable)collectionViewLayout waterFlow:(BOOL)waterFlow;

@property (nonatomic, strong, readonly) NSMutableArray <DZXNewCollectionSection *> *sections;
// 默认NO
@property (nonatomic, assign) BOOL sectionHeadersPinToVisibleBounds;

@property (nonatomic, copy) void (^didSelectedItem) (UICollectionView *collectionView, DZXNewCollectionItem *cellItem);

- (void)reloadData;

- (void)addSection:(DZXNewCollectionSection *)section;

- (void)removeSection:(DZXNewCollectionSection *)section;

- (void)removeSectionAtIndex:(NSInteger)index;

- (void)removeAllSection;

- (void)insertSection:(DZXNewCollectionSection *)section atIndex:(NSInteger)index;

- (void)replaceAllSections:(NSArray <DZXNewCollectionSection *> *)sections;

@end

NS_ASSUME_NONNULL_END
