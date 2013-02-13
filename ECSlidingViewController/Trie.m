//
//  Trie.m
//  tree
//
//  Created by HengHong on 23/1/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import "Trie.h"

@implementation Trie

-(id) init
{
    self = [super init];
    if (self) {
        self.root = [[TrieNode alloc]init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.root = (TrieNode*)[decoder decodeObjectForKey:@"root"];
    }

    NSLog(@"done init %@",self.root );
    for (TrieNode* tn  in self.root.childTrieNodes) {
        NSLog(@"children = %@",tn);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.root forKey:@"root"];
}

-(void) addWord:(NSString*)s withId:(NSString*)objId
{

    TrieNode* current = self.root;
    if ( s.length == 0 )
    {
        current.isLeafNode = true; // an empty word
        return;
    }
    
    for ( int i = 0; i < s.length; i++ )
    {

        TrieNode* child = [current findChild:[s characterAtIndex:i]];
        if ( child != NULL )
        {
            current = child;
        }
        else
        {
            TrieNode* tmp = [[TrieNode alloc]init];
            tmp.content = [s characterAtIndex:i];
            [current appendChild:tmp];
            current = tmp;
        }
        if ( i == s.length - 1 ){
            current.isLeafNode = true;
            [current.objId addObject:objId];
        }
    }
}

-(BOOL)searchWord:(NSString*)s //should return all words 
{
    TrieNode* current = self.root;
    
    while ( current != NULL )
    {
        for ( int i = 0; i < s.length; i++ )
        {
            TrieNode* tmp = [current findChild:[s characterAtIndex:i]];
            if ( tmp == NULL )
                return false;
            current = tmp;
        }
        if (current.isLeafNode)
            return true;
        else
            return false;
    }
    
    return false;
}
-(NSMutableArray*)autoCompleteWordsWithInput:(NSString*)s
{
    
    TrieNode* current = self.root;
    if (current == NULL) {
        return NULL; //shoudlnt get here
    }
    for ( int i = 0; i < s.length; i++ )
    {
        TrieNode* tmp = [current findChild:[s characterAtIndex:i]];
        if ( tmp == NULL )
            return NULL;
        current = tmp;
    }
        return [self findAllChildWords:current];
}
-(NSMutableArray*)findAllChildWords:(TrieNode*)root
{
    if (root == NULL) {
        return NULL;
    }
    if (root.isLeafNode && root.childTrieNodes.count==0) {
        return root.objId;
    }
    NSMutableArray* retArray = [[NSMutableArray alloc]init];
    [retArray addObjectsFromArray:root.objId];
    for (TrieNode* tn in root.childTrieNodes)
    {
        
        [retArray addObjectsFromArray:[self findAllChildWords:tn]];
    }

    return retArray;


}


@end
