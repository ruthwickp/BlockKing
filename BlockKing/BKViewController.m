//
//  BKViewController.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/25/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKViewController.h"

@interface BKViewController ()
// Stores height of blocks to drop from top of device
@property (nonatomic, strong) NSNumber *height;

@property (nonatomic, strong) UIView *shootingAreaView; // Shooting area view
@property (nonatomic, strong) NSMutableAttributedString *timerText; // Text to display time
@property (nonatomic, strong) UILabel *timerLabel; // Label to display time
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation BKViewController

// Lazy instantiation
- (NSNumber *)height
{
    if (!_height) {
        _height = [[NSNumber alloc] initWithInt:0];
    }
    return _height;
}

// Designs the game and starts the game
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTapGestureRecognizer];
    [self drawTimer];
    [self startGame];
}


#pragma mark - Shooting Area methods

// Shooting area constants
#define SHOOTING_AREA_HEIGHT .10
#define SHOOTING_AREA_BORDER 3.0

// Lazy instantiation
- (UIView *)shootingAreaView
{
    if (!_shootingAreaView) {
        // Displays shooting area at bottom of view
        CGFloat x = 0;
        CGFloat y = (self.view.bounds.size.height * (1 - SHOOTING_AREA_HEIGHT));
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height * SHOOTING_AREA_HEIGHT;
        CGRect shootingAreaRect = CGRectMake(x, y, width, height);
        
        // Creates frame design and adds the subview to it
        _shootingAreaView = [[UIView alloc] initWithFrame:shootingAreaRect];
        _shootingAreaView.layer.borderColor = [[UIColor blackColor] CGColor];
        _shootingAreaView.layer.borderWidth = SHOOTING_AREA_BORDER;
        [_shootingAreaView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:.2]];
        [self.view addSubview:_shootingAreaView];
    }
    return _shootingAreaView;
}

// Adds the tap Gesture to shooting area
- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fireBullet)];
    [self.shootingAreaView addGestureRecognizer:tapGesture];
}

- (void)fireBullet
{
    NSLog(@"Fire Bullet");
}

#pragma mark - Game Design

#define TEXT_HEIGHT 30.0
#define INITIALIZE_HEIGHT_OFFSET 30.0
#define TEXT_SIZE 20.0
#define TIMER_STRING_LENGTH 7 // Length of string Timer:

// Lazy instantiation
- (UILabel *)timerLabel
{
    if (!_timerLabel) {
        // Draws label on top right of screen
        CGFloat x = 0;
        CGFloat y = INITIALIZE_HEIGHT_OFFSET;
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = TEXT_HEIGHT;
        CGRect timerLabelRect = CGRectMake(x, y, width, height);
        
        // Creates label and adds to view
        _timerLabel = [[UILabel alloc] initWithFrame:timerLabelRect];
        [self.view addSubview:_timerLabel];
    }
    return _timerLabel;
}

// Lazy instantiation
- (NSMutableAttributedString *)timerText
{
    if (!_timerText) {
        // Creates the text
        _timerText = [[NSMutableAttributedString alloc] initWithString:@"Timer: 00.00"];
        
        // Adds text color
        [_timerText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor blackColor]
                           range:NSMakeRange(0, TIMER_STRING_LENGTH)];
        [_timerText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor greenColor]
                           range:NSMakeRange(TIMER_STRING_LENGTH, _timerText.length - TIMER_STRING_LENGTH)];
        
        // Adds text font
        [_timerText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Verdana-BoldItalic" size:TEXT_SIZE]
                           range:NSMakeRange(0, _timerText.length)];
    }
    return _timerText;
}

// Draws the timer on the screen
- (void)drawTimer
{
    self.timerLabel.attributedText = self.timerText;
}

#pragma mark - Game Play

- (void)startGame
{
    [self startTimer];
    [self startDroppingBlocks];
}

// Starts the timer
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(updateTimerLabel:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateTimerLabel:(NSTimer *)timer
{
    // Increments the time
    static int sec = 0;
    static int min = 0;
    sec++;
    if (sec > 59) {
        sec = 0;
        min++;
    }
    
    // Creates a time string
    NSString *timeString;
    if (min < 10 && sec < 10) {
        timeString = [NSString stringWithFormat:@"0%d.0%d", min, sec];
    }
    else if (min < 10 && sec >= 10) {
        timeString = [NSString stringWithFormat:@"0%d.%d", min, sec];
    }
    else if (min >= 10 && sec < 10) {
        timeString = [NSString stringWithFormat:@"%d.0%d", min, sec];
    }
    else {
        timeString = [NSString stringWithFormat:@"%d.%d", min, sec];
    }
    
    // Updates timer label
    NSMutableString *timerLabelString = self.timerText.mutableString;
    [timerLabelString replaceCharactersInRange:NSMakeRange(TIMER_STRING_LENGTH, self.timerText.length - TIMER_STRING_LENGTH)
                                    withString:timeString];
    self.timerLabel.attributedText = self.timerText;
}

- (void)startDroppingBlocks
{
    
}



@end
