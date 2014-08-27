//
//  BKAppDelegate.m
//  BlockKing
//
//  Created by Ruthwick Pathireddy on 8/25/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "BKAppDelegate.h"

@interface BKAppDelegate ()
@property (strong, nonatomic) UIManagedDocument *document;
@end

@implementation BKAppDelegate

// Lazily instantiates the managed document
- (UIManagedDocument *)document
{
    if (!_document) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = @"BlockKing";
        NSURL *documentURL = [documentDirectory URLByAppendingPathComponent:documentName];
        _document = [[UIManagedDocument alloc] initWithFileURL:documentURL];
        
    }
    return _document;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Creates NSManagedObjectContext
    [self createContext];
    return YES;
}

// Creates or opens UIManagedDocument
- (void)createContext
{
    // Checks if file exists and opens it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self.document fileURL] path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            }
            else {
                NSLog(@"Error, could not open file");
            }
        }];
    }
    // Creates file if it doesn't exist
    else {
        [self.document saveToURL:[self.document fileURL]
                forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
                   if (success) {
                       [self documentIsReady];
                   }
                   else {
                       NSLog(@"Error, could not create file");
                   }
               }];
    }
}

// Sets the context when document is ready
- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.context = self.document.managedObjectContext;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
