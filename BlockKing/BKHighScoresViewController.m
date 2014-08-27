//
//  BKHighScoresViewController.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/27/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKHighScoresViewController.h"
#import "BKAppDelegate.h"
#import "Score.h"

@interface BKHighScoresViewController ()
// Labels for high scores
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel1;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel2;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel3;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel4;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel5;

// Context for high scores
@property (nonatomic, strong) NSManagedObjectContext *context;

// Stores the outlet labels
@property (nonatomic, strong) NSArray *outletLabels;

@end

@implementation BKHighScoresViewController

// Lazy instantiation
- (NSManagedObjectContext *)context
{
    if (!_context) {
        BKAppDelegate *appDelegate = (BKAppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = appDelegate.context;
    }
    return _context;
}

- (NSArray *)outletLabels
{
    if (!_outletLabels) {
        _outletLabels = [[NSArray alloc] initWithObjects:self.highScoreLabel1, self.highScoreLabel2, self.highScoreLabel3, self.highScoreLabel4, self.highScoreLabel5, nil];
    }
    return _outletLabels;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setHighScores];
}

#define TEXT_SIZE 20

// Sets the high scores on the text label
- (void)setHighScores
{
    NSArray *highScores = [self fetchHighScores];
    NSMutableArray *scoresText = [[NSMutableArray alloc] init];
    
    for (Score *score in highScores) {
        // Gets the date in string format
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:score.time];
        
        NSMutableAttributedString *scoreText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   %@", score.gameScore, dateString]];

        // Adds text color
        [scoreText addAttribute:NSForegroundColorAttributeName
                          value:[UIColor greenColor]
                          range:NSMakeRange(0, score.gameScore.length + 1)];
        [scoreText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor blackColor]
                           range:NSMakeRange(score.gameScore.length + 1, dateString.length)];
        
        // Adds text font
        [scoreText addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"Verdana-BoldItalic" size:TEXT_SIZE]
                          range:NSMakeRange(0, scoreText.length)];
        
        // Centers the text
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [scoreText addAttribute:NSParagraphStyleAttributeName
                          value:paragraphStyle
                          range:NSMakeRange(0, scoreText.length)];
        
        // Stores them in array
        [scoresText addObject:scoreText];
    }
    
    // Adds them to the label
    for (int i = 0; i < [scoresText count]; i++) {
        [[self.outletLabels objectAtIndex:i] setAttributedText:scoresText[i]];
    }
}

// Returns an array containing the Top 5 high scores
- (NSArray *)fetchHighScores
{
    // Makes a request for the given entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"gameScore" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    
    // Finds matches from request
    NSError *error;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];
    if (error || !matches) {
        NSLog(@"Error when fetching scores: %@", error);
        return nil;
    }
    if ([matches count] > 5) {
        return [matches objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 5)]];
    }
    else {
        return matches;
    }
}

// Returns to home page
- (IBAction)homeButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
