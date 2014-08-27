//
//  BKHomeViewController.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/26/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKHomeViewController.h"
#import "BKViewController.h"

@implementation BKHomeViewController

// Unwind segue
- (IBAction)finishedGame:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[BKViewController class]]) {
        NSLog(@"Finished game");
    }
}

@end
