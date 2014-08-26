//
//  BKViewController.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/25/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKViewController.h"

@interface BKViewController ()

@property (nonatomic, strong) UIView *shootingAreaView; // Shooting area view
@property (nonatomic, strong) NSMutableAttributedString *timerText; // Text to display time
@property (nonatomic, strong) UILabel *timerLabel; // Label to display time
@property (nonatomic, strong) NSTimer *timer;

// Animation Behaviors
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIPushBehavior *push;
@property (nonatomic, strong) UIDynamicItemBehavior *bulletItemBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *blockItemBehavior;

@property (nonatomic, strong) NSMutableArray *allBlocks; // Array of UIView blocks
@property (nonatomic, strong) NSMutableArray *allBullets; // Array of UIView bullets
@end

@implementation BKViewController

// Designs the game and starts the game
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTapGestureRecognizer];
    [self drawTimer];
    [self startGame];
}

// Lazy instantiation
- (NSMutableArray *)allBlocks
{
    if (!_allBlocks) {
        _allBlocks = [[NSMutableArray alloc] init];
    }
    return _allBlocks;
}

// Lazy instantiation
- (NSMutableArray *)allBullets
{
    if (!_allBullets) {
        _allBullets = [[NSMutableArray alloc] init];
    }
    return _allBullets;
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
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fireBullet:)];
    [self.shootingAreaView addGestureRecognizer:tapGesture];
}

#define BULLET_SIZE 20.0

// Creates a bullet (circle) and fires it
- (void)fireBullet:(UITapGestureRecognizer *)tapGesture
{
    // Creates location of bullet
    CGPoint location = [tapGesture locationOfTouch:0 inView:self.view];
    CGFloat x = location.x - BULLET_SIZE / 2;
    CGFloat y = location.y - BULLET_SIZE / 2;
    CGRect bulletViewRect = CGRectMake(x, y, BULLET_SIZE, BULLET_SIZE);
    bulletViewRect.origin.y -= (y + BULLET_SIZE - self.shootingAreaView.frame.origin.y);
    
    // Creates a bulletView
    UIView *bulletView = [[UIView alloc] initWithFrame:bulletViewRect];
    bulletView.layer.cornerRadius = BULLET_SIZE / 2;
    [bulletView setBackgroundColor:[UIColor blackColor]];
    
    // Adds the bullet to the view
    [self addBulletBehavior:bulletView];
    [self.view addSubview:bulletView];
    [self.allBullets addObject:bulletView];
    
    // Removes the bullet after one second
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(removeBullet:)
                                   userInfo:nil
                                    repeats:NO];
}

// Removes bullet from view
- (void)removeBullet:(NSTimer *)timer
{
    UIView *bulletView = [self.allBullets firstObject];
    [self.allBullets removeObjectAtIndex:0];
    [self removeBulletBehavior:bulletView];
    [bulletView removeFromSuperview];
}

#pragma mark - Game Design

#define TEXT_HEIGHT 20.0
#define TEXT_HEIGHT_OFFSET_Y 20.0
#define TEXT_SIZE 20.0
#define TIMER_STRING_LENGTH 7 // Length of string Timer:

// Lazy instantiation
- (UILabel *)timerLabel
{
    if (!_timerLabel) {
        // Draws label on top right of screen
        CGFloat x = 0;
        CGFloat y = TEXT_HEIGHT_OFFSET_Y;
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

float droppingBlockTimeInterval = 2.0;
float minDropTimeInterval = .2;
#define BLOCK_SIZE 40
#define BLOCK_OFFSET_Y 40
#define BLOCK_BORDER_WIDTH 1.0

// Starts dropping blocks every second
- (void)startDroppingBlocks
{
    [NSTimer scheduledTimerWithTimeInterval:droppingBlockTimeInterval
                                     target:self
                                   selector:@selector(dropBlock:)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:.2f
                                     target:self
                                   selector:@selector(updateBlocks:)
                                   userInfo:nil
                                    repeats:YES];
    
}

#define MAX_BLOCKS 50

// Drops block and decreases time interval
- (void)dropBlock:(NSTimer *)timer
{
    // Creates random frame for block
    CGFloat x = ((int)(arc4random_uniform(self.view.bounds.size.width) / BLOCK_SIZE)) * BLOCK_SIZE;
    CGRect blockRect = CGRectMake(x, BLOCK_OFFSET_Y, BLOCK_SIZE, BLOCK_SIZE);
    
    // Creates a block view with color
    UIView *blockView = [[UIView alloc] initWithFrame:blockRect];
    [blockView setBackgroundColor:[self randomColor]];
    blockView.layer.borderColor = [[UIColor blackColor] CGColor];
    blockView.layer.borderWidth = BLOCK_BORDER_WIDTH;
    
    // Adds behavior to block ands adds block to view
    [self addBlockBehavior:blockView];
    [self.view addSubview:blockView];
    [self.allBlocks addObject:blockView];

    // Stop game is there are a lot of blocks
    if ([self.allBlocks count] > MAX_BLOCKS) {
        [self stopGame];
        return;
    }
    
    // Decrease time interval
    if (droppingBlockTimeInterval > minDropTimeInterval) {
        droppingBlockTimeInterval -= .1;

    }
    [NSTimer scheduledTimerWithTimeInterval:droppingBlockTimeInterval
                                     target:self
                                   selector:@selector(dropBlock:)
                                   userInfo:nil
                                    repeats:NO];
}

// Stops the game and pops up an alert
- (void)stopGame
{
    // Stops the timer
    [self.timer invalidate];
    self.timer = nil;
    
    // Displays game over message
    NSString *gameOverMessage = [NSString stringWithFormat:@"GAME OVER. TIME: %@", [self.timerText.string substringFromIndex:TIMER_STRING_LENGTH]];
    [self alert:gameOverMessage];
}

// Shows an alert view containing the following message
- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"BlockKing"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Ok", nil] show];
}


// Removes all blocks that are not on screen from view
- (void)updateBlocks:(NSTimer *)timer
{
    // Gather the blocks to remove and removes them
    NSMutableArray *removeBlocks = [[NSMutableArray alloc] init];
    [self.allBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIView class]]) {
            CGPoint centerPoint = CGPointMake(((UIView *)obj).frame.origin.x + BLOCK_SIZE / 2, ((UIView *)obj).frame.origin.y + BLOCK_SIZE / 2);
            if (!CGRectContainsPoint(self.view.frame, centerPoint)) {
                [removeBlocks addObject:obj];
            }
        }
    }];
    
    [removeBlocks enumerateObjectsWithOptions:NSEnumerationReverse
                                   usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       [self removeBlockBehavior:(UIView *)obj];
                                       [(UIView *)obj removeFromSuperview];
                                   }];
    [self.allBlocks removeObjectsInArray:removeBlocks];
}

// Returns a random color
- (UIColor *)randomColor
{
    NSArray *randomColor = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor blueColor],
                            [UIColor yellowColor], [UIColor greenColor], nil];
    return randomColor[arc4random_uniform([randomColor count])];
}

#pragma mark - Animation

// Lazy instantiation
- (UIDynamicAnimator *)dynamicAnimator
{
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] init];
    }
    return _dynamicAnimator;
}

#define GRAVITY_MAGNITUDE 1.0

// Lazy instantiation
- (UIDynamicBehavior *)gravity
{
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        _gravity.magnitude = GRAVITY_MAGNITUDE;
        [self.dynamicAnimator addBehavior:_gravity];
    }
    return _gravity;
}

// Lazy instantiation
- (UICollisionBehavior *)collision
{
    if (!_collision) {
        // Adds bottom, left, and right boundary
        _collision = [[UICollisionBehavior alloc] init];
        [_collision addBoundaryWithIdentifier:@"ShootingAreaBoundary"
                                    fromPoint:self.shootingAreaView.frame.origin
                                      toPoint:CGPointMake(self.shootingAreaView.frame.origin.x + self.shootingAreaView.frame.size.width, self.shootingAreaView.frame.origin.y)];
        [_collision addBoundaryWithIdentifier:@"LeftBoundary"
                                    fromPoint:self.view.frame.origin
                                      toPoint:CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height)];
        [_collision addBoundaryWithIdentifier:@"RightBoundary"
                                    fromPoint:CGPointMake(self.view.frame.origin.x + self.view.frame.size.width, self.view.frame.origin.y)
                                      toPoint:CGPointMake(self.view.frame.origin.x + self.view.frame.size.width, self.view.frame.origin.y + self.view.frame.size.height)];
        [self.dynamicAnimator addBehavior:_collision];
    }
    return _collision;
}

#define PUSH_FORCE -5.0

// Lazy instantiation
- (UIPushBehavior *)push
{
    if (!_push) {
        _push = [[UIPushBehavior alloc] init];
        _push.pushDirection = CGVectorMake(0, PUSH_FORCE);
        [self.dynamicAnimator addBehavior:_push];
    }
    return _push;
}

#define BULLET_ITEM_DENSITY 10.0

// Lazy instantiation
- (UIDynamicItemBehavior *)bulletItemBehavior
{
    if (!_bulletItemBehavior) {
        _bulletItemBehavior = [[UIDynamicItemBehavior alloc] init];
        [_bulletItemBehavior setDensity:BULLET_ITEM_DENSITY];
        [self.dynamicAnimator addBehavior:_bulletItemBehavior];
    }
    return _bulletItemBehavior;
}

#define BLOCK_ITEM_ELASTICITY .4

- (UIDynamicItemBehavior *)blockItemBehavior
{
    if (!_blockItemBehavior) {
        _blockItemBehavior = [[UIDynamicItemBehavior alloc] init];
        [_blockItemBehavior setElasticity:BLOCK_ITEM_ELASTICITY];
        [self.dynamicAnimator addBehavior:_blockItemBehavior];
    }
    return _blockItemBehavior;
}

// Adds block behavior for view
- (void)addBlockBehavior:(UIView *)block
{
    [self.gravity addItem:block];
    [self.collision addItem:block];
    [self.blockItemBehavior addItem:block];
}

// Adds bullet behavior for view
- (void)addBulletBehavior:(UIView *)bullet
{
    [self.collision addItem:bullet];
    [self.push addItem:bullet];
    [self.bulletItemBehavior addItem:bullet];
}

// Removes a block behavior
- (void)removeBlockBehavior:(UIView *)block
{
    [self.gravity removeItem:block];
    [self.collision removeItem:block];
    [self.blockItemBehavior removeItem:block];
}

// Removes bullet behavior
- (void)removeBulletBehavior:(UIView *)bullet
{
    [self.collision removeItem:bullet];
    [self.push removeItem:bullet];
    [self.bulletItemBehavior removeItem:bullet];
}

@end
