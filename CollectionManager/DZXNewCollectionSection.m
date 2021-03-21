//
//  DZCollectionSection.m
//  DZCollectionView
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 mac. All rights reserved.
//

#import "DZXNewCollectionSection.h"
#import "DZXNewCollectionItem.h"

@implementation DZXNewCollectionSection

+ (instancetype)section {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cellItems = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)addCellItem:(__kindof DZXNewCollectionItem *)cellItem {
    [self.cellItems addObject:cellItem];
}

- (void)addCellItems:(NSArray <__kindof DZXNewCollectionItem *> *)cellItems {
    [self.cellItems addObjectsFromArray:cellItems];
}

- (void)removeCellItem:(__kindof DZXNewCollectionItem *)cellItem {
    [self.cellItems removeObject:cellItem];
}

- (void)removeAllItems {
    [self.cellItems removeAllObjects];
}

- (void)insertCellItem:(__kindof DZXNewCollectionItem *)cellItem atIndex:(NSInteger)index {
    [self.cellItems insertObject:cellItem atIndex:index];
}

- (void)replaceAllCellItems:(NSArray <DZXNewCollectionItem *> *)cellItems {
    [self.cellItems removeAllObjects];
    [self.cellItems addObjectsFromArray:cellItems];
}

- (void)updateCellItemMainColor:(NSString *)colorString {
    for (DZXNewCollectionItem *item in self.cellItems) {
        item.mainColor = colorString;
    }
}

@end
