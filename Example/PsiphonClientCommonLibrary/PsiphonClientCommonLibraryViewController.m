/*
 * Copyright (c) 2017, Psiphon Inc.
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */


#import "PsiphonClientCommonLibraryViewController.h"
#import "RegionAdapter.h"

@interface PsiphonClientCommonLibraryViewController ()

@end

@implementation PsiphonClientCommonLibraryViewController {
	PsiphonSettingsViewController *appSettingsViewController;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	RegionAdapter *regionAdapter = [RegionAdapter sharedInstance];
	[regionAdapter onAvailableEgressRegions:[regionAdapter getAllPossibleRegionCodes]];
	[self addOpenSettingsButton];
}

- (void)openPsiphonSettings {
	// Assume previous view controller has been dismissed
	appSettingsViewController = [[PsiphonSettingsViewController alloc] init];
	appSettingsViewController.delegate = appSettingsViewController;
	appSettingsViewController.showCreditsFooter = NO;
	appSettingsViewController.showDoneButton = YES;
	appSettingsViewController.neverShowPrivacySettings = YES;
	appSettingsViewController.settingsDelegate = self;

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:appSettingsViewController];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)addOpenSettingsButton {
	UIButton *openSettingsButton = [[UIButton alloc] init];
	[openSettingsButton setTitle:@"Open Settings" forState:UIControlStateNormal];
	[openSettingsButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[openSettingsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	openSettingsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	CGFloat height = 100;
	openSettingsButton.layer.cornerRadius = height / 2;
	openSettingsButton.layer.borderColor = [UIColor blueColor].CGColor;
	openSettingsButton.layer.borderWidth = 1.f;

	[self.view addSubview:openSettingsButton];

	// Setup autolayout
	openSettingsButton.translatesAutoresizingMaskIntoConstraints = NO;

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:openSettingsButton
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.f
														   constant:0]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:openSettingsButton
														  attribute:NSLayoutAttributeCenterY
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterY
														 multiplier:1.f
														   constant:0]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:openSettingsButton
														  attribute:NSLayoutAttributeHeight
														  relatedBy:NSLayoutRelationEqual
															 toItem:nil
														  attribute:NSLayoutAttributeNotAnAttribute
														 multiplier:1.f
														   constant:height]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:openSettingsButton
														  attribute:NSLayoutAttributeWidth
														  relatedBy:NSLayoutRelationEqual
															 toItem:openSettingsButton
														  attribute:NSLayoutAttributeHeight
														 multiplier:2.f
														   constant:0]];

	[openSettingsButton addTarget:self action:@selector(openPsiphonSettings) forControlEvents:UIControlEventTouchUpInside];
}


# pragma mark - PsiphonSettingsViewControllerDelegate methods

- (void)notifyPsiphonConnectionState {
	// no action needed for example
}

- (void)reloadAndOpenSettings {
	__weak PsiphonClientCommonLibraryViewController *weakSelf = self;
	[appSettingsViewController dismissViewControllerAnimated:NO completion:^{
        __strong PsiphonClientCommonLibraryViewController *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->appSettingsViewController = nil;
            [strongSelf openPsiphonSettings];
        }
	}];
}

- (void)settingsWillDismissWithForceReconnect:(BOOL)forceReconnect {
	// no action needed for example
}

- (BOOL)shouldEnableSettingsLinks {
	return YES; // always on in example
}

- (void)userPressedURL:(NSURL *)URL viewController:(FeedbackViewController *)viewController {
	dispatch_async(dispatch_get_main_queue(), ^{
		[[UIApplication sharedApplication] openURL:URL];
	});
}

- (void)userSubmittedFeedback:(NSUInteger)selectedThumbIndex comments:(NSString *)comments email:(NSString *)email uploadDiagnostics:(BOOL)uploadDiagnostics viewController:(FeedbackViewController *)viewController {
	// no action needed for example
}

@end
