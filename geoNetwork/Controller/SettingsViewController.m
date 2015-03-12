//
//  SettingsViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 1/18/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import "SettingsViewController.h"
#import "LibraryAPI.h"
#import "Settings.h"
#import "UIColor_Extension.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //color
    self.navigationController.navigationBar.barTintColor = [UIColor appPrimaryColor];
    
    self.navigationItem.leftBarButtonItem.title = @"Close";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewControllerDefault)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
}

- (void)dismissViewControllerDefault {
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect settingsRect = self.navigationController.view.frame;
                         settingsRect.origin.y += self.view.window.frame.size.height;
                         self.navigationController.view.frame = settingsRect;
                     } completion:^(BOOL finished) {
                         [self.navigationController.view removeFromSuperview];
                         [self.navigationController removeFromParentViewController];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
