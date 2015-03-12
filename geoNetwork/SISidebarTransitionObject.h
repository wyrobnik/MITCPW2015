//
//  SITransitionObject.h
//  SISidebar
//
//  Created by David Wyrobnik on 12/23/14.
//  Copyright (c) 2014 David Wyrobnik. All rights reserved.
//
// This class takes a parentViewController and any viewController that should be displayed modally as a sidebar

#import <UIKit/UIKit.h>

@interface SISidebarTransitionObject : UIPercentDrivenInteractiveTransition <UIViewControllerTransitioningDelegate>

//Init using this function and assign the two controllers.
-(id)initWithParentViewController:(UIViewController *)viewController withSidebar:(UIViewController *)sidebarVC;

//Call this function to reveal sidebar. (All other logic/closing/panning etc. gets handled by this class
-(void)showSidebar;

@property (nonatomic, readonly) UIViewController *parentViewController;
@property (nonatomic, strong) UIViewController *sidebarViewController;

@property (nonatomic) CGFloat animationDuration;
@property (nonatomic, readonly) BOOL sidebarIsOpen;
@property (nonatomic) CGFloat relativeWidth;
@property (nonatomic, strong) UIColor *statusBarBackgroundColor; //when sidebar appears


//Note, functions that can be used to reveal/hide sidebar (from parentViewController):
//if (!self.transitionObject.sidebarIsOpen)
//    [self presentViewController:self.sidebar animated:YES completion:nil];
//else
//    [self.sidebar dismissViewControllerAnimated:YES completion:nil];



@end
