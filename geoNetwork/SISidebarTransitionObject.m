//
//  SITransitionObject.m
//  SISidebar
//
//  Created by David Wyrobnik on 12/23/14.
//  Copyright (c) 2014 David Wyrobnik. All rights reserved.
//

//Inspired by https://github.com/TeehanLax/UIViewController-Transitions-Example/blob/master/UIViewController-Transitions-Example/TLMenuInteractor.m

#import "SISidebarTransitionObject.h"

//SET this to 0, if want sidebar to show underneath
#define SIDEBAR_ABOVE 0


@interface SISidebarTransitionObject () <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) BOOL sidebarIsOpen;
@property (nonatomic) BOOL interactive;
@property (nonatomic) CGFloat sidebarWidth;
@property (nonatomic) CGRect sidebarBounds;  //The sidebar bounds are set depending on parent view controller and relativeWidth
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

#if SIDEBAR_ABOVE
@property (nonatomic, strong) UIView *darkOverlayMain; //To darken background
@property (nonatomic, strong) UIView *statusBarBackgroundView;
#endif

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *screenEdgePanSidebarGestureRecognizer;

@end

@implementation SISidebarTransitionObject

#define MAX_DARKENING_ALPHA 0.5f

#pragma mark - Public Methods

-(id)initWithParentViewController:(UIViewController *)viewController withSidebar:(UIViewController *)sidebarVC {
    if (!(self = [super init])) return nil;
    
    _parentViewController = viewController;
    _sidebarViewController = sidebarVC;
    [self setupParentVC];
    [self setupSidebarVC];
    return self;
}

- (void)showSidebar {
    [self.parentViewController presentViewController:self.sidebarViewController animated:YES completion:nil];
}

# pragma mark - setup functions

-(void)setupParentVC {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Initialize screenEdgePanGestureRecogizer that open sidebar (main view)
        self.screenEdgePanSidebarGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panSidebar:)];
        [self.screenEdgePanSidebarGestureRecognizer setDelegate:self];
        [self.screenEdgePanSidebarGestureRecognizer setEdges:UIRectEdgeLeft];
        [self.screenEdgePanSidebarGestureRecognizer setMinimumNumberOfTouches:1];
        [self.screenEdgePanSidebarGestureRecognizer setEnabled:YES];
        self.screenEdgePanSidebarGestureRecognizer.cancelsTouchesInView = YES;
        [self.parentViewController.view addGestureRecognizer:self.screenEdgePanSidebarGestureRecognizer];
    #if SIDEBAR_ABOVE
            //Setup darkening of mainController
            self.darkOverlayMain = [[UIView alloc] initWithFrame:self.parentViewController.navigationController.view.frame];
            [self.parentViewController.navigationController.view addSubview:self.darkOverlayMain];
    //        [self.parentViewController.navigationController.view addSubview:self.darkOverlayMain];
            self.darkOverlayMain.backgroundColor = [UIColor blackColor];
            self.darkOverlayMain.alpha = 0.0;
    #endif
    });
}

- (void)setupSidebarVC {
    self.sidebarViewController.modalPresentationStyle = UIModalPresentationCustom;
    self.sidebarViewController.transitioningDelegate = self;
    self.sidebarViewController.modalPresentationCapturesStatusBarAppearance = YES;
}

# pragma mark - sidebar status changes or will change

-(void)sidebarWillAppear {
    #if SIDEBAR_ABOVE
        self.sidebarViewController.view.frame = CGRectOffset(self.sidebarBounds, -self.sidebarWidth, 0);  //Start frame
    #else
        self.sidebarViewController.view.frame = CGRectOffset(self.sidebarBounds, 0, 0);
    #endif
    
    static dispatch_once_t onceToken;  //TODO need to do this when sidebar gets changed
    dispatch_once(&onceToken, ^{
        //setup tapGestureRecognizer
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToClose:)];
        self.tapGestureRecognizer.delegate = self;
        self.tapGestureRecognizer.cancelsTouchesInView = NO;
        [self.parentViewController.navigationController.view.window addGestureRecognizer:self.tapGestureRecognizer];
        
        //setup PanGesture to control sidebar
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSidebar:)];
        [self.panGestureRecognizer setDelegate:self];
        [self.panGestureRecognizer setMinimumNumberOfTouches:1];
        [self.panGestureRecognizer setEnabled:NO];
        [self.parentViewController.navigationController.view.window addGestureRecognizer:self.panGestureRecognizer];
    #if SIDEBAR_ABOVE
        //Setup shadow of sidebar
        self.sidebarViewController.view.layer.masksToBounds = NO;
        self.sidebarViewController.view.layer.shadowOffset = CGSizeMake(10, 0);
        self.sidebarViewController.view.layer.shadowRadius = 5;
        self.sidebarViewController.view.layer.shadowOpacity = 0.5;
        //Pick line to set shadow, or not
        [self.sidebarViewController.view.layer setShadowColor:[[UIColor blackColor] CGColor]];
        
        //Setup statusbar background color
        self.statusBarBackgroundView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
        [self.sidebarViewController.view.window addSubview:self.statusBarBackgroundView];
//        self.statusBarBackgroundView.backgroundColor = self.statusBarBackgroundColor;
        self.statusBarBackgroundColor = [UIColor clearColor];
    #else
        //Setup shadow of parentViewController
        self.parentViewController.navigationController.view.layer.masksToBounds = NO;
        self.parentViewController.navigationController.view.layer.shadowOffset = CGSizeMake(-10, 0);
        self.parentViewController.navigationController.view.layer.shadowRadius = 10;
        self.parentViewController.navigationController.view.layer.shadowOpacity = 0.8f;
        //Pick line to set shadow, or not
        [self.parentViewController.navigationController.view.layer setShadowColor:[[UIColor blackColor] CGColor]];
        
        
    #endif
    });

    #if SIDEBAR_ABOVE
    //    self.statusBarBackgroundView.alpha = 0.0f;
        self.statusBarBackgroundView.alpha = 1.0f;
    #endif
    
    self.tapGestureRecognizer.enabled = YES;
    self.parentViewController.navigationController.view.userInteractionEnabled = NO;
    
    //hide statusbar
//    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //Keep parentNavigationFrame to jump
//    CGRect parentNavigationFrame = self.parentViewController.navigationController.navigationBar.frame;
//    parentNavigationFrame.size.height += statusBarFrame.size.height;
//    self.parentViewController.navigationController.navigationBar.frame = parentNavigationFrame;
    //Keep sidebarNavigationFrame to jump
//    if ([self.sidebarViewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController *sidebarNavigationController = (UINavigationController*)self.sidebarViewController;
//        CGRect sidebarNavigationFrame = sidebarNavigationController.navigationBar.frame;
//        sidebarNavigationFrame.size.height -= statusBarFrame.size.height;
//        sidebarNavigationController.navigationBar.frame = sidebarNavigationFrame;
//    }
    
    
}

-(void)sidebarDidAppear {
    self.sidebarIsOpen = YES;
    self.interactive = NO;
    self.panGestureRecognizer.enabled = YES;
}

-(void)sidebarWillDisappear {
    self.sidebarViewController.view.frame = self.sidebarBounds;
    
    [self.parentViewController viewWillAppear:YES];
    
}

-(void)sidebarDidDisappear {
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    #if !SIDEBAR_ABOVE
    //hacky. This fixes the problem of the window turning black after a complete transition
    [[UIApplication sharedApplication].keyWindow addSubview:self.parentViewController.navigationController.view];
    #endif
    
    #if SIDEBAR_ABOVE
        self.statusBarBackgroundView.alpha = 0.0f;
    #endif
    self.sidebarIsOpen = NO;
    self.interactive = NO;
    
    self.tapGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = NO;
    self.parentViewController.navigationController.view.userInteractionEnabled = YES;
    
}

# pragma mark - Gesture Recognizer functions
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:self.screenEdgePanSidebarGestureRecognizer]) {
        return YES;
    }
    return NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:self.screenEdgePanSidebarGestureRecognizer]) {
        return YES;
    }
    return NO;
}

-(void)tapToClose:(UITapGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self.sidebarViewController.view];
    if (!CGRectContainsPoint(self.sidebarViewController.view.frame, location)) {
        [self.sidebarViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#define SIDEBAR_EDGE_WIDTH 30.0f
-(void)panSidebar:(UIPanGestureRecognizer*)panGesture {
    static BOOL ignorePan = NO;
#if SIDEBAR_ABOVE
    CGPoint location = [panGesture locationInView:self.parentViewController.navigationController.view];
#else
    CGPoint location = [panGesture locationInView:self.sidebarViewController.view];
#endif
    CGPoint velocity = [panGesture velocityInView:self.parentViewController.navigationController.view];
    CGFloat ratio;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            //Check that pan started in right end of sidebar
            if ([panGesture isEqual:self.panGestureRecognizer] &&
                [panGesture locationInView:self.sidebarViewController.view].x < self.sidebarWidth - SIDEBAR_EDGE_WIDTH) {
                //toggle to cancel touch
                ignorePan = YES;
                self.panGestureRecognizer.enabled = NO;
                self.panGestureRecognizer.enabled = YES;
                return;
            }
            self.interactive = YES;
            if (!self.sidebarIsOpen) {
                [self.parentViewController presentViewController:self.sidebarViewController animated:YES completion:nil];
            } else
                [self.sidebarViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            ratio = location.x / CGRectGetWidth(self.sidebarViewController.view.bounds);
            [self updateInteractiveTransition:ratio];
            break;
        case UIGestureRecognizerStateCancelled:
            if (ignorePan) {  //If pan should be ignored, then setting panGesture.enabled = NO, causes Cancelled to be triggered
                ignorePan = NO;
                return;
            }
            //NO BREAK, because this should move on then to ended
        case UIGestureRecognizerStateEnded:
            if ((velocity.x > 0 && !self.sidebarIsOpen) || (velocity.x < 0 && self.sidebarIsOpen)) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

-(void)animationEnded:(BOOL)transitionCompleted {
    self.interactive = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.interactive)
        return;

    
    if (!self.sidebarIsOpen) {
        [transitionContext.containerView addSubview:self.sidebarViewController.view];
        #if !SIDEBAR_ABOVE
            [transitionContext.containerView addSubview:self.parentViewController.navigationController.view];
        #endif
    }
    #if !SIDEBAR_ABOVE
        if (self.sidebarIsOpen) {
            [transitionContext.containerView addSubview:self.sidebarViewController.view];
            [transitionContext.containerView addSubview:self.parentViewController.navigationController.view];
        }
    #endif
    
    
    self.sidebarIsOpen ? [self sidebarWillDisappear] : [self sidebarWillAppear];

    #if SIDEBAR_ABOVE
        CGRect endFrame = self.sidebarBounds;
        endFrame.origin.x = -self.sidebarIsOpen*self.sidebarWidth;
    #else
        CGRect endFrame = self.parentViewController.navigationController.view.frame;
        endFrame.origin.x = !self.sidebarIsOpen*self.sidebarWidth;
    #endif
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        #if SIDEBAR_ABOVE
            self.sidebarViewController.view.frame = endFrame;
            self.darkOverlayMain.alpha = self.sidebarIsOpen ? 0.0 : MAX_DARKENING_ALPHA;
    //        self.statusBarBackgroundView.alpha = self.sidebarIsOpen ? 0.0f : 1.0f;
        #else
            self.parentViewController.navigationController.view.frame = endFrame;
        #endif
        
    } completion:^(BOOL finished) {
        self.sidebarIsOpen ? [self sidebarDidDisappear] : [self sidebarDidAppear];
        [transitionContext completeTransition:YES];
    }];
}


# pragma mark - UIViewInteractiveTransitioning Methods

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    if (!self.sidebarIsOpen) {
        [transitionContext.containerView addSubview:self.sidebarViewController.view];
        #if !SIDEBAR_ABOVE
            [transitionContext.containerView addSubview:self.parentViewController.navigationController.view];
        #endif
    }
    #if !SIDEBAR_ABOVE
    if (self.sidebarIsOpen) {
        [transitionContext.containerView addSubview:self.sidebarViewController.view];
        [transitionContext.containerView addSubview:self.parentViewController.navigationController.view];
    }
    #endif
    self.sidebarIsOpen ? [self sidebarWillDisappear] : [self sidebarWillAppear];
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    percentComplete = MIN(1.0f, percentComplete);
    
    #if SIDEBAR_ABOVE
        self.sidebarViewController.view.frame = CGRectOffset(self.sidebarBounds,
                                                             -self.sidebarWidth * (1.0f -percentComplete), 0);
        
        self.darkOverlayMain.alpha = MAX_DARKENING_ALPHA * percentComplete;
    //    self.statusBarBackgroundView.alpha = percentComplete;
    #else
        self.parentViewController.navigationController.view.frame =
        CGRectOffset(self.parentViewController.navigationController.view.bounds,
                 self.sidebarWidth * percentComplete, 0);
    #endif
}


- (void)finishInteractiveTransition {

    #if SIDEBAR_ABOVE
    CGRect endFrame = self.sidebarBounds;
    endFrame.origin.x = -self.sidebarIsOpen*self.sidebarWidth;
    #else
    CGRect endFrame = self.parentViewController.navigationController.view.frame;
    endFrame.origin.x = !self.sidebarIsOpen*self.sidebarWidth;
    #endif
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        #if SIDEBAR_ABOVE
            self.sidebarViewController.view.frame = endFrame;
            self.darkOverlayMain.alpha = self.sidebarIsOpen ? 0.0 : MAX_DARKENING_ALPHA;
        //        self.statusBarBackgroundView.alpha = self.sidebarIsOpen ? 0.0f : 1.0f;
        #else
            self.parentViewController.navigationController.view.frame = endFrame;
        #endif
    } completion:^(BOOL finished) {
        [self.transitionContext completeTransition:YES];
        self.sidebarIsOpen ? [self sidebarDidDisappear] : [self sidebarDidAppear];
    }];
}

- (void)cancelInteractiveTransition {
    #if SIDEBAR_ABOVE
        CGRect endFrame = self.sidebarBounds;
        endFrame.origin.x = -!self.sidebarIsOpen * self.sidebarWidth;
    #else
        CGRect endFrame = self.parentViewController.navigationController.view.frame;
        endFrame.origin.x = self.sidebarIsOpen * self.sidebarWidth;
    #endif
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        #if SIDEBAR_ABOVE
            self.sidebarViewController.view.frame = endFrame;
            self.darkOverlayMain.alpha = !self.sidebarIsOpen ? 0.0 : MAX_DARKENING_ALPHA;
            //        self.statusBarBackgroundView.alpha = !self.sidebarIsOpen ? 0.0f : 1.0f;
        #else
            self.parentViewController.navigationController.view.frame = endFrame;
        #endif
    } completion:^(BOOL finished) {
        [self.transitionContext completeTransition:NO];
        !self.sidebarIsOpen ? [self sidebarDidDisappear] : [self sidebarDidAppear];
    }];
}


#pragma mark - Getter and Setters

- (CGFloat)animationDuration {
    if (_animationDuration == 0.0f)
        _animationDuration = 0.3f;
    return _animationDuration;
}

- (CGFloat)relativeWidth {
    if (_relativeWidth == 0.0f)
        _relativeWidth = 0.8f;
    return _relativeWidth;
}

- (CGFloat)sidebarWidth {
    return CGRectGetWidth(self.parentViewController.navigationController.view.frame) * self.relativeWidth;
}

- (CGRect)sidebarBounds {
    return CGRectMake(0,0, self.sidebarWidth, self.parentViewController.navigationController.view.window.frame.size.height);
}

@synthesize statusBarBackgroundColor = _statusBarBackgroundColor;

- (UIColor *)statusBarBackgroundColor {
    if (!_statusBarBackgroundColor) {
        _statusBarBackgroundColor =  [UIColor blackColor];
    }
    return _statusBarBackgroundColor;
}

#if SIDEBAR_ABOVE
- (void)setStatusBarBackgroundColor:(UIColor *)statusBarBackgroundColor {
    _statusBarBackgroundColor = statusBarBackgroundColor;
    self.statusBarBackgroundView.backgroundColor = statusBarBackgroundColor;
}
#endif

- (void)setSidebarViewController:(UIViewController *)sidebarViewController {
    _sidebarViewController = sidebarViewController;
    [self setupSidebarVC];
}




@end
