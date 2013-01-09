
#import "DealsLayout.h"
#define kStackSpace 5
#define kMaxItemsOnStack 5
#define kTableHeight 75.0f
#define kBottomStackHeight 40.0f
#define kBottomStackPadding 10.0f
#define kTableCoverHeight 100
@implementation DealsLayout
@synthesize kLayoutStateRef;
-(void)prepareLayout
{
    // NSLog(@"preparing for layout..%d cells",self.cellCount);
    [super prepareLayout];
    
}

-(CGSize)collectionViewContentSize
{
    if (self.cellCount > 4) {
        return CGSizeMake(self.collectionView.bounds.size.width, self.cellCount*kTableHeight+kTableCoverHeight);
    }else{
        return CGSizeMake(self.collectionView.bounds.size.width, self.cellCount*kTableHeight+kTableCoverHeight+320);
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.zIndex = path.item;
    attributes.hidden = NO;
    switch (kLayoutStateRef) {
        case kLayoutStateTable:
            if(path.item==0){
                attributes.frame = CGRectMake(0,path.item*kTableHeight,self.collectionView.bounds.size.width,self.collectionView.bounds.size.height - kBottomStackHeight);
                
            }else{
                attributes.frame = CGRectMake(0,path.item*kTableHeight+kTableCoverHeight,self.collectionView.bounds.size.width,self.collectionView.bounds.size.height - kBottomStackHeight);
            }
            [self.collectionView setScrollEnabled:YES];
            break;
            
        case kLayoutStateDetail:
            
            if([self.collectionView cellForItemAtIndexPath:path].selected)
            {
                attributes.frame = CGRectMake(0,  self.prevOffset.y ,self.collectionView.bounds.size.width, self.collectionView.bounds.size.height-kBottomStackHeight-kBottomStackPadding);
                
            }
            else
            {
                if (path.item > kMaxItemsOnStack)
                {
                    attributes.hidden =YES;
                    attributes.frame = CGRectMake(0,self.prevOffset.y + self.collectionView.bounds.size.height ,self.collectionView.bounds.size.width,self.collectionView.bounds.size.height-kBottomStackHeight);
                }
                else
                {
                    attributes.frame = CGRectMake(0,self.prevOffset.y + self.collectionView.bounds.size.height-kBottomStackHeight+(MIN(kMaxItemsOnStack,path.item)*kStackSpace),self.collectionView.bounds.size.width,self.collectionView.bounds.size.height-kBottomStackHeight);
                }
            }
            [self.collectionView setScrollEnabled:NO];
            break;
        default:
            break;
    }
     
    
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    
    for (NSInteger i=0 ; i < self.cellCount; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        if(kLayoutStateRef == kLayoutStateDetail)
        {
            NSLog(@"layout detail");
            if (CGRectContainsPoint(rect, [self.collectionView cellForItemAtIndexPath:indexPath].center))
            {
                [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        }
        else
        {
            NSLog(@"layout table");
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];

        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    // attributes.center =CGPointMake(self.collectionView.bounds.size.width/2,self.collectionView.bounds.size.height);
    attributes.alpha =0.0f;
    
    return attributes;
}

//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    attributes.alpha = 0.0;
//    attributes.center = CGPointMake(_center.x, _center.y);
//    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
//    return attributes;
//}

@end
