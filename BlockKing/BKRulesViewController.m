//
//  BKRulesViewController.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/27/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKRulesViewController.h"

@interface BKRulesViewController ()

@end

@implementation BKRulesViewController

// Returns to home page
- (IBAction)homeButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
