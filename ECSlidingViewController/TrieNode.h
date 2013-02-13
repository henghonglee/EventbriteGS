//
//  TrieNode.h
//  tree
//
//  Created by HengHong on 23/1/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrieNode : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray* childTrieNodes;
@property (nonatomic) BOOL isLeafNode;
@property (nonatomic) unichar content;
@property (nonatomic,strong) NSMutableArray*objId;
-(TrieNode*) findChild:(unichar)c;
-(void) appendChild:(TrieNode*) child;
@end
