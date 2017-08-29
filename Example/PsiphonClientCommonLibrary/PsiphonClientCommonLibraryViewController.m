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
#import "PsiphonSettingsViewController.h"
#import "UpstreamProxySettings.h"

@interface PsiphonClientCommonLibraryViewController ()

@end

@implementation PsiphonClientCommonLibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self openPsiphonSettings];
}

- (void)openPsiphonSettings
{
	PsiphonSettingsViewController *appSettingsViewController;

	if (appSettingsViewController == nil) {
		appSettingsViewController = [[PsiphonSettingsViewController alloc] init];
		appSettingsViewController.delegate = appSettingsViewController;
		appSettingsViewController.showCreditsFooter = NO;
		appSettingsViewController.showDoneButton = YES;
		appSettingsViewController.neverShowPrivacySettings = YES;
	}

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:appSettingsViewController];
	[self presentViewController:navController animated:YES completion:nil];
}

@end
