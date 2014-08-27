//
//  BKHomeViewController.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/26/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKHomeViewController.h"
#import "BKViewController.h"
#import <CoreData/CoreData.h>
#import "Score.h"
#import "BKAppDelegate.h"

@interface BKHomeViewController ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation BKHomeViewController

// Lazy instantiation
- (NSManagedObjectContext *)context
{
    if (!_context) {
        BKAppDelegate *appDelegate = (BKAppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = appDelegate.context;
    }
    return _context;
}

// Unwind segue
- (IBAction)finishedGame:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[BKViewController class]]) {
        BKViewController *gameViewController = segue.sourceViewController;
        [self createScore:gameViewController.time];
    }
}

// Creates the score in core data
- (void)createScore:(NSString *)score
{
    Score *scoreManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Score"
                                                 inManagedObjectContext:self.context];
    scoreManagedObject.gameScore = score;
    scoreManagedObject.time = [NSDate date];
}

@end
