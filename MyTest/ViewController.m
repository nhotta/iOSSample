//
//  ViewController.m
//  MyTest
//
//  Created by Naoki Hotta on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// * Add 2 menu items for the text selection
// * Look up the JSON (placeholder) to retrieve related text for the selection
// * Present the items as tableview in either Modal or pop over

#import "ViewController.h"
#import "tableViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize theWebView;
@synthesize popoverController;
@synthesize relatedTypeKey;
@synthesize selection;



-(void)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)showTableInNavView:(NSArray *)data {
    tableViewController *tvc = [[tableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tvc.relatedItems = data;
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
    [nvc setNavigationBarHidden:NO];
    
    tvc.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)] autorelease];
    tvc.navigationItem.title = selection;
    
    [self presentModalViewController:nvc animated:YES];
    
    [tvc release];
    [nvc release];
}

- (void)showTableInPopOver:(NSArray *)data {
    // existing popover
    if (self.popoverController)
    {
        [self.popoverController dismissPopoverAnimated:NO];
        self.popoverController = nil;
    }
    
    if (!self.popoverController) {
        tableViewController *tvc = [[tableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        tvc.contentSizeForViewInPopover = CGSizeMake(320, 400);
        tvc.relatedItems = data;
        UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
        [nvc setNavigationBarHidden:NO];
        tvc.navigationItem.title = selection;
       
        self.popoverController = [[UIPopoverController alloc]initWithContentViewController:nvc];
        self.popoverController.delegate = self;
        [tvc release];
        [nvc release];
        
        if(!self.popoverController.popoverVisible) {
            [self.popoverController presentPopoverFromRect:CGRectMake(self.view.frame.origin.x, 
                                                                      self.view.frame.origin.y, 72, 37) 
                                                    inView:self.view                        
                                  permittedArrowDirections:0 
                                                  animated:YES];  
        } 
        
    }
}

- (void)fetchedData:(NSData *)responseData {
//    NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"fetchedData:%@", str);
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass) {
        return;
    }

    NSError *error;
    NSDictionary *json = [NSJSONSerialization 
                          JSONObjectWithData:responseData                          
                          options:kNilOptions 
                          error:&error];
    
    NSArray *relatedItems = [json objectForKey:relatedTypeKey];
    NSLog(@"%@ of %@: %@", relatedTypeKey, selection, relatedItems);
    NSLog(@"Retain Count:%d", [selection retainCount]);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self showTableInPopOver:relatedItems];
    }
    else {
        [self showTableInNavView:relatedItems];
    }
}

- (void) getRelated {
    self.selection = [theWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    NSLog(@"getRelatedConcepts:%@", selection);

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [[NSBundle mainBundle] pathForResource:@"Related" 
                                                              ofType:@"json"];    
        NSURL *url = [NSURL fileURLWithPath:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchedData:) 
                               withObject:data waitUntilDone:YES];
    } );
}

- (IBAction)getRelatedArticles:(id)sender {
    self.relatedTypeKey = @"Articles";
    [self getRelated];
}

- (IBAction)getRelatedConcepts:(id)sender {
    self.relatedTypeKey = @"Concepts";
    [self getRelated];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"index" 
                                                           ofType:@"html"];    
    NSURL *url = [NSURL fileURLWithPath:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [theWebView loadRequest:request];
    
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *getRelatedArticles = [[UIMenuItem alloc] initWithTitle: @"Related Articles" action: @selector(getRelatedArticles:)];
    UIMenuItem *getRelatedConcepts = [[UIMenuItem alloc] initWithTitle: @"Related Concepts" action: @selector(getRelatedConcepts:)];
    [menuController setMenuItems: [NSArray arrayWithObjects:getRelatedArticles, getRelatedConcepts, nil]];
    [getRelatedArticles release];
    [getRelatedConcepts release];
    
}

- (void)viewDidUnload
{
    [self setTheWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.popoverController)
    {
        [self.popoverController dismissPopoverAnimated:NO];
        self.popoverController = nil;
    }
}

- (void)dealloc {
    [theWebView release];
    [popoverController release];
    [relatedTypeKey release];
    [selection release];
    [super dealloc];
}
@end
