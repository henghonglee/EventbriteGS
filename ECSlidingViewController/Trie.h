//
//  Trie.h
//  tree
//
//  Created by HengHong on 23/1/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrieNode.h"
@interface Trie : NSObject<NSCoding>

@property (nonatomic, retain) TrieNode* root;
-(void) addWord:(NSString*)s withId:(NSString*)objId;
-(BOOL) searchWord:(NSString*) s;
-(NSMutableArray*)autoCompleteWordsWithInput:(NSString*)s;
@end
