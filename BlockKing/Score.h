//
//  Score.h
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/26/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Score : NSManagedObject

@property (nonatomic, retain) NSString * gameScore;
@property (nonatomic, retain) NSDate * time;

@end
