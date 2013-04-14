//
//  RSChatSectionInfo.h
//  RenrenSixin
//
//  Created by 陶宁 on 11-11-10.
//  Copyright (c) 2011年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSFamilyNameInfo : NSObject <NSCoding>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSIndexPath *indexPath;
- (id)initWithName:(NSString *)n ofIndexPath:(NSIndexPath*)ip;
@end


@interface RNFriendsSectionInfo : NSObject <NSCoding>{
    NSString *_letter;
    NSMutableArray *_familyArray;
}
@property (nonatomic, copy) NSString *letter;
@property (nonatomic, retain) NSMutableArray *familyArray;


- (NSIndexPath*)indexPathOfFamilyName:(NSString *)name;
- (BOOL)addFamilyInfo:(RSFamilyNameInfo*)info;
- (NSArray*)familyNameArrayForLetter:(NSString*)letter;
@end
