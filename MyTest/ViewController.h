//
//  ViewController.h
//  MyTest
//
//  Created by Naoki Hotta on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPopoverControllerDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *theWebView;
@property (retain, nonatomic) UIPopoverController *popoverController;
@property (copy, nonatomic) NSString *relatedTypeKey;
@property (copy, nonatomic) NSString *selection;  // text selection in webView

@end
