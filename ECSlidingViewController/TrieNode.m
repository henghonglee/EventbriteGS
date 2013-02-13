//
//  TrieNode.m
//  tree
//
//  Created by HengHong on 23/1/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import "TrieNode.h"

@implementation TrieNode

-(id)init
{
    self = [super init];
    if (self) {
        self.childTrieNodes = [[NSMutableArray alloc]init];
        self.objId = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.childTrieNodes = [decoder decodeObjectForKey:@"childTrieNodes"];
        NSLog(@"children = %d",self.childTrieNodes.count);
        self.isLeafNode = [decoder decodeBoolForKey:@"isLeafNode"];
        self.objId = [decoder decodeObjectForKey:@"objId"];
        NSNumber* character = [decoder decodeObjectForKey:@"content"];
        self.content = character.charValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSNumber* new = [NSNumber numberWithChar:self.content];
    [encoder encodeObject:self.childTrieNodes forKey:@"childTrieNodes"];
    [encoder encodeBool:self.isLeafNode forKey:@"isLeafNode"];
    [encoder encodeObject:self.objId forKey:@"objId"];
    [encoder encodeObject:new forKey:@"content"];
}


-(TrieNode*) findChild:(unichar)c
{
    for ( int i = 0; i < self.childTrieNodes.count; i++ )
    {
        TrieNode* tmp = [self.childTrieNodes objectAtIndex:i];
        if ( tmp.content == c )
        {
            return tmp;
        }
    }
    return NULL; //not found
}
-(void) appendChild:(TrieNode*) child
{
    [self.childTrieNodes addObject:child];
}
@end
