//
//  Pinyin.h
//  RenrenSixin
//
//  Created by 陶宁 on 11-11-7.
//  Copyright (c) 2011年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

char pinyinFirstLetter(unsigned short hanzi);
char pinyinAllLetters(unsigned short hanzi,char *pinyinChars);

@interface Pinyin : NSObject 
{
	NSDictionary *_map;
	NSMutableArray *_observers;
}

@property (retain) NSDictionary *map;
@property (nonatomic, retain) NSMutableArray *observers;

+ (Pinyin *)getInstance;
- (void)loadMap;
- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;
@end

////////////////////////////////////////////////////////////////

@protocol PinyinDelegate
- (void)pinyinLoaded;
@end


