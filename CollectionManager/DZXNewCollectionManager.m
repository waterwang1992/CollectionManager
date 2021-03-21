//
//  DZCollectionManager.m
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import "DZXNewCollectionManager.h"
#import "DZXNewCollectionSection.h"
#import "DZXNewCollectionItem.h"
#import "DZXNewCollectionHeaderFooterViewItem.h"
#import "DZXNewCollectionCellProtocol.h"
#import "DZXNewCollectionHeaderFooterProtocol.h"

@interface DZXNewCollectionManager()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) DZCollectionViewWaterfallFlowLayout *layout;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, readwrite, strong) NSMutableSet *reuseCellSet;

@property (nonatomic, readwrite, strong) NSMutableSet *reuseHeaderSet;

@property (nonatomic, readwrite, strong) NSMutableSet *reuseFooterSet;

@end

@implementation DZXNewCollectionManager

+ (instancetype)managerWithCollectionView:(UICollectionView *)collectionView {
    return [[self alloc] initWithCollectionView:collectionView
                           collectionViewLayout:nil
                                      waterFlow:NO];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                  collectionViewLayout:(UICollectionViewLayout *)collectionViewLayout waterFlow:(BOOL)waterFlow{
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        self.reuseCellSet = [NSMutableSet set];
        self.reuseHeaderSet = [NSMutableSet set];
        self.reuseFooterSet = [NSMutableSet set];
        _sections = [NSMutableArray array];
        
        if ([collectionView.collectionViewLayout isKindOfClass:[DZCollectionViewWaterfallFlowLayout class]]) {
            DZCollectionViewWaterfallFlowLayout *layout = (DZCollectionViewWaterfallFlowLayout *)collectionView.collectionViewLayout;
            layout.dataSource = self;
        }else if (waterFlow) {
            DZCollectionViewWaterfallFlowLayout *layout = [[DZCollectionViewWaterfallFlowLayout alloc] init];
            layout.dataSource = self;
            [self.collectionView setCollectionViewLayout:layout];
        }
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    }
    return self;
}

- (void)setSectionHeadersPinToVisibleBounds:(BOOL)sectionHeadersPinToVisibleBounds {
    self.layout.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds;
}

#pragma mark - safe mehtod

- (DZXNewCollectionSection *)safeSectionAtSection:(NSInteger)section {
    if (section < self.sections.count) {
        DZXNewCollectionSection *sec= [self.sections objectAtIndex:section];
        return sec;
    }
    return nil;
}

- (DZXNewCollectionItem *)safeItemAtRow:(NSInteger)row inSection:(DZXNewCollectionSection *)section {
    if (row < section.cellItems.count) {
        DZXNewCollectionItem *item = [section.cellItems objectAtIndex:row];
        return item;
    }
    return nil;
}

- (DZXNewCollectionItem *)safeItemAtIndexPath:(NSIndexPath *)indexPath {
    DZXNewCollectionSection *section = [self safeSectionAtSection:indexPath.section];
    if (section) {
        DZXNewCollectionItem *item = [self safeItemAtRow:indexPath.row inSection:section];
        return item;
    }
    return nil;
}


#pragma mark - get cell identifier

- (NSString *)validCellIdentifierWithItem:(DZXNewCollectionItem *)item {
    if (item.cellIdentifier) {
        return item.cellIdentifier;
    }
    return NSStringFromClass([self validCellClassWithItem:item]);
}

#pragma mark - get cell class

- (Class)validCellClassWithItem:(DZXNewCollectionItem *)item {
    if (item.cellClass) {
        return item.cellClass;
    }
    return UICollectionViewCell.class;

}

#pragma mark - get cell height

- (CGSize)validCellSizeWithItem:(DZXNewCollectionItem *)cellItem layout:(UICollectionViewLayout *)layout {
    // 如果要求隐藏, 则直接返回0
    if (cellItem.hiddenRow) return  CGSizeZero;
    // 如果没给宽度, 则直接返回0
    if (cellItem.width <= 0) return CGSizeZero;
    if (cellItem.height < 0.01 || cellItem.dynamicHeight) { // 如果没有给高度, 或者已经指明需要实时动态计算高度, 则尝试计算系统压缩高度
        Class cellClass = [self validCellClassWithItem:cellItem];
        NSString *path = [[NSBundle mainBundle] pathForResource:NSStringFromClass(cellClass) ofType:@"nib"];
        if (!path) {// 如果不是nib文件才尝试去压缩高度
            id <DZXNewCollectionCellProtocol>cell = [[cellClass alloc] init];
            if ([cell conformsToProtocol:@protocol(DZXNewCollectionCellProtocol)] && [cell respondsToSelector:@selector(configCellItem:)]) {
                // 用现有数据源去刷新对应内容, 如果布局是自撑高的, 则会计算出压缩高度
                [cell configCellItem:cellItem];
                CGSize cellSize = [(UICollectionViewCell *)cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                // 这里将高度缓存起来, 以便复用, 因为这里相对是比较耗费性能的, 这也是不要随意设置dynamicHeight的原因
                cellItem.height = cellSize.height;
            }
        }
    }
    if (cellItem.height) {
        return CGSizeMake(cellItem.width, cellItem.height);
    }
    if ([layout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)layout;
        return flow.itemSize;
    }
    return CGSizeZero;
}

#pragma mark - get reuse view identifier
- (NSString *)reuseIdentifierForHeaderFooterItem:(DZXNewCollectionHeaderFooterViewItem *)item {
    NSString *identifier;
    if (item.headerFooterIdentifier) {
        return item.headerFooterIdentifier;
    }
    return identifier ?: NSStringFromClass([self validClassForHeaderFooterItem:item]);
}

#pragma mark - get reuse view class
- (Class)validClassForHeaderFooterItem:(DZXNewCollectionHeaderFooterViewItem *)item {
    return item.headerFooterClass ?: UICollectionReusableView.class;
}

#pragma mark - get Reuse Height

- (CGSize)validReuseSizeForHeaderFooterItem:(DZXNewCollectionHeaderFooterViewItem *)item {
    if (item) {
        NSLog(@"clarence height%f", item.height);
    }
    if (item && !item.hidden) {
        return CGSizeMake(self.collectionView.frame.size.width, item.height);
    }
    return CGSizeZero;
}

#pragma mark UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    return sec.cellItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DZXNewCollectionItem *cellItem = [self safeItemAtIndexPath:indexPath];
    NSString *cellIdentifier = [self validCellIdentifierWithItem:cellItem];
    Class cellClass = [self validCellClassWithItem:cellItem];
    if (![self.reuseCellSet containsObject:cellIdentifier]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:NSStringFromClass(cellClass) ofType:@"nib"];
        if (path) {
            [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
        } else {
            [collectionView registerClass:cellClass forCellWithReuseIdentifier:cellIdentifier];
        }
        [self.reuseCellSet addObject:cellIdentifier];
    }
    
    UICollectionViewCell <DZXNewCollectionCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(DZXNewCollectionCellProtocol)] && [cell respondsToSelector:@selector(configCellItem:)]) {
        [cell configCellItem:cellItem];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DZXNewCollectionSection *seciton = [self safeSectionAtSection:indexPath.section];
    
    DZXNewCollectionHeaderFooterViewItem *headerFooterItem = nil;
    NSMutableSet *reuseSet;
    if (kind == UICollectionElementKindSectionHeader) {
        headerFooterItem = seciton.headerItem;
        reuseSet = self.reuseHeaderSet;
    } else if (kind == UICollectionElementKindSectionFooter) {
        headerFooterItem = seciton.footerItem;
        reuseSet = self.reuseFooterSet;
    } else {
        return nil;
    }
    
    Class cls = [self validClassForHeaderFooterItem:headerFooterItem];
    NSString *identifier = [self reuseIdentifierForHeaderFooterItem:headerFooterItem];
    
    if (![reuseSet containsObject:identifier]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:NSStringFromClass(cls) ofType:@"nib"];
        if (path) {
            [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cls) bundle:nil] forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
        } else {
            [collectionView registerClass:cls forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
        }
        [reuseSet addObject:identifier];
    }
    
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    if ([view conformsToProtocol:@protocol(DZXNewCollectionHeaderFooterProtocol)]) {
        UICollectionReusableView<DZXNewCollectionHeaderFooterProtocol> *tmpView = (UICollectionReusableView<DZXNewCollectionHeaderFooterProtocol> *)view;
        [tmpView configHeaderFooterViewItem:headerFooterItem];
    }
    if (headerFooterItem.backgroundColor) {
        view.backgroundColor = headerFooterItem.backgroundColor;
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    return [self validReuseSizeForHeaderFooterItem:sec.headerItem];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    return [self validReuseSizeForHeaderFooterItem:sec.footerItem];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DZXNewCollectionItem *cellItem = [self safeItemAtIndexPath:indexPath];
    CGSize size = [self validCellSizeWithItem:cellItem layout:collectionViewLayout];
    return size;
}

// cell即将出现
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DZXNewCollectionItem *cellItem = [self safeItemAtIndexPath:indexPath];
    cellItem.indexPath = indexPath;
    if (cellItem.willDisplay) {
        cellItem.willDisplay(cell, cellItem, indexPath);
    }
    if ([cell conformsToProtocol:@protocol(DZXNewCollectionCellProtocol)] && [cell respondsToSelector:@selector(configWillDisplayCellItem:)]) {
        [((id<DZXNewCollectionCellProtocol>)cell) configWillDisplayCellItem:cellItem];
    }
}

// cell 已经消失
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    DZXNewCollectionItem *cellItem = [self safeItemAtIndexPath:indexPath];
    if (cellItem.didEndDisplay) {
        cellItem.indexPath = nil;
        cellItem.didEndDisplay(cell, cellItem, indexPath);
    }
    if ([cell conformsToProtocol:@protocol(DZXNewCollectionCellProtocol)] && [cell respondsToSelector:@selector(configEndDisplayCellItem:)]) {
        [((id<DZXNewCollectionCellProtocol>)cell) configEndDisplayCellItem:cellItem];
    }
}

// head/footer 即将出现
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    DZXNewCollectionSection *section = [self safeSectionAtSection:indexPath.section];
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        DZXNewCollectionHeaderFooterViewItem *headerViewItem = section.headerItem;
        if (headerViewItem == nil) {
            return;
        }
        UICollectionReusableView *headerView = (UICollectionReusableView *)view;
        if (headerViewItem.willDisplay) {
            headerViewItem.willDisplay(headerView, headerViewItem, indexPath.section);
        }
    }else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]){
        DZXNewCollectionHeaderFooterViewItem *fooderViewItem = section.footerItem;
        if (fooderViewItem == nil) {
            return;
        }
        UICollectionReusableView *footerView = (UICollectionReusableView *)view;
        if (fooderViewItem.willDisplay) {
            fooderViewItem.willDisplay(footerView, fooderViewItem, indexPath.section);
        }
    }
}

// 消失
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    DZXNewCollectionSection *section = [self safeSectionAtSection:indexPath.section];
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        DZXNewCollectionHeaderFooterViewItem *headerViewItem = section.headerItem;
        if (headerViewItem == nil) {
            return;
        }
        UICollectionReusableView *headerView = (UICollectionReusableView *)view;
        if (headerViewItem.didEndDisplay) {
            headerViewItem.didEndDisplay(headerView, headerViewItem, indexPath.section);
        }
    }else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]){
        DZXNewCollectionHeaderFooterViewItem *fooderViewItem = section.footerItem;
        if (fooderViewItem == nil) {
            return;
        }
        UICollectionReusableView *footerView = (UICollectionReusableView *)view;
        if (fooderViewItem.didEndDisplay) {
            fooderViewItem.didEndDisplay(footerView, fooderViewItem, indexPath.section);
        }
    }
}

// 选中
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    DZXNewCollectionItem *cellItem = [self safeItemAtIndexPath:indexPath];
    if (cellItem.didSelectRow) {
        cellItem.didSelectRow(cellItem, indexPath);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:cellItem:)]) {
        [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath cellItem:cellItem];
    }
}

#pragma mark - DZCollectionViewWaterfallFlowLayoutDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout numberOfColumnInSection:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    if (sec) {
        return sec.columnInSection;
    }
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    DZXNewCollectionItem *item = [self safeItemAtIndexPath:indexPath];
    return [self validCellSizeWithItem:item layout:layout].height;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    return sec.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    return sec.minimumInteritemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout insetForSectionAtIndex:(NSInteger)section {
    
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    if (sec) {
        return sec.insetForSection;
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    CGFloat height = [self validReuseSizeForHeaderFooterItem:sec.headerItem].height;
    return height;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DZCollectionViewWaterfallFlowLayout*)layout referenceHeightForFooterInSection:(NSInteger)section {
    DZXNewCollectionSection *sec = [self safeSectionAtSection:section];
    CGFloat height = [self validReuseSizeForHeaderFooterItem:sec.footerItem].height;
    return height;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}

#pragma mark - private methods

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)addSection:(DZXNewCollectionSection *)section{
    [self.sections addObject:section];
}

- (void)removeSection:(DZXNewCollectionSection *)section{
    [self.sections removeObject:section];
}

-(void)removeAllSection {
    [self.sections removeAllObjects];
}

- (void)removeSectionAtIndex:(NSInteger)index {
    if (index < (self.sections.count - 1)) {
        [self.sections removeObjectAtIndex:index];
    }
}

- (void)insertSection:(DZXNewCollectionSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:section atIndex:index];
}

- (void)replaceAllSections:(NSArray <DZXNewCollectionSection *>*)sections{
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:sections];
    [self.collectionView reloadData];
}

@end
