/*
 * Copyright (c) 2016, Psiphon Inc.
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


#import "IASKSettingsReader.h"
#import "IASKTextField.h"
#import "LogViewController.h"
#import "PsiphonSettingsTextFieldViewCell.h"
#import "RegionAdapter.h"
#import "RegionSelectionViewController.h"
#import "PsiphonClientCommonLibraryHelpers.h"
#import "PsiphonSettingsViewController.h"
#import "UIImage+CountryFlag.h"
#import "UpstreamProxySettings.h"

#define kAboutSpecifierKey @"about"
#define kFAQSpecifierKey @"faq"
#define kFeedbackSpecifierKey @"feedback"
#define kHttpsEverywhereSpecifierKey @"httpsEverywhere"
#define kLogsSpecifierKey @"logs"
#define kPrivacyPolicySpecifierKey @"privacyPolicy"
#define kTermsOfUseSpecifierKey @"termsOfUse"
#define kTutorialSpecifierKey @"tutorial"

static BOOL (^safeStringsEqual)(NSString *, NSString *) = ^BOOL(NSString *a, NSString *b) {
	return (([a length] == 0) && ([b length] == 0)) || ([a isEqualToString:b]);
};

@implementation PsiphonSettingsViewController {
	BOOL forceReconnectRequired;
	BOOL isRTL;
}

static NSArray *links;
BOOL linksEnabled;

- (void)viewDidLoad
{
	[super viewDidLoad];
	isRTL = ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft);

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		links = @[kAboutSpecifierKey, kFAQSpecifierKey, kPrivacyPolicySpecifierKey, kTermsOfUseSpecifierKey];
	});

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
	[center addObserver:self selector:@selector(updateLinksState:) name:kPsiphonConnectionStateNotification object:nil];
	[center addObserver:self selector:@selector(updateAvailableRegions:) name:kPsiphonAvailableRegionsNotification object:nil];
	[center addObserver:self selector:@selector(updateAvailableRegions:) name:kPsiphonSelectedNewRegionNotification object:nil];

	[self setHiddenKeys];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	linksEnabled = [self shouldEnableSettingsLinks];
}

- (void)dealloc
{
	// Remove observers here and not in viewDidDisappear.
	// Otherwise (e.g) when languages view is pushed this view
	// disappears and the notifaction generated by changing app
	// language will be missed.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setHiddenKeys {
	// These keys correspond to settings in PsiphonOptions.plist
	BOOL upstreamProxyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kUseUpstreamProxy];
	BOOL useUpstreamProxyAuthentication = upstreamProxyEnabled && [[NSUserDefaults standardUserDefaults] boolForKey:kUseProxyAuthentication];

	NSArray *upstreamProxyKeys = [NSArray arrayWithObjects:kUpstreamProxyHostAddress, kUpstreamProxyPort, kUseProxyAuthentication, nil];
	NSArray *proxyAuthenticationKeys = [NSArray arrayWithObjects:kProxyUsername, kProxyPassword, kProxyDomain, nil];

	// Hide configurable fields until user chooses to use upstream proxy
	NSMutableSet *hiddenKeys = upstreamProxyEnabled ? nil : [NSMutableSet setWithArray:upstreamProxyKeys];

	// Hide authentication fields until user chooses to use upstream proxy with authentication
	if (!useUpstreamProxyAuthentication) {
		if (hiddenKeys == nil) {
			hiddenKeys = [NSMutableSet setWithArray:proxyAuthenticationKeys];
		} else {
			[hiddenKeys addObjectsFromArray:proxyAuthenticationKeys];
		}
	}

	self.hiddenKeys = hiddenKeys;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier {
	NSString *identifier = [NSString stringWithFormat:@"%@-%@-%ld-%d", specifier.key, specifier.type, (long)specifier.textAlignment, !!specifier.subtitle.length];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
	}

	cell.userInteractionEnabled = YES;

	if ([specifier.key isEqualToString:kUpstreamProxyPort]
		|| [specifier.key isEqualToString:kUpstreamProxyHostAddress]
		|| [specifier.key isEqualToString:kProxyUsername]
		|| [specifier.key isEqualToString:kProxyDomain]
		|| [specifier.key isEqualToString:kProxyPassword]) {

		cell = [[PsiphonSettingsTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIASKPSTextFieldSpecifier];

		cell.textLabel.text = specifier.title;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;

		NSString *textValue = [self.settingsStore objectForKey:specifier.key] != nil ? [self.settingsStore objectForKey:specifier.key] : specifier.defaultStringValue;
		if (textValue && ![textValue isMemberOfClass:[NSString class]]) {
			textValue = [NSString stringWithFormat:@"%@", textValue];
		}
		IASKTextField *textField = ((IASKPSTextFieldSpecifierViewCell*)cell).textField;
		textField.secureTextEntry = [specifier.key isEqualToString:kProxyPassword];
		textField.text = textValue;
		textField.key = specifier.key;
		textField.placeholder = specifier.placeholder;
		textField.delegate = self;
		textField.keyboardType = specifier.keyboardType;
		textField.autocapitalizationType = specifier.autocapitalizationType;
		textField.autocorrectionType = specifier.autoCorrectionType;
		textField.textAlignment = specifier.textAlignment;
		textField.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
		[((IASKPSTextFieldSpecifierViewCell*)cell).textField addTarget:self action:@selector(IASKTextFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
	} else if ([specifier.key isEqualToString:kLogsSpecifierKey]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = specifier.title;
#ifndef DEBUGLOGS
		cell.hidden = YES;
#endif
	} else if ([specifier.key isEqualToString:kFeedbackSpecifierKey] || [specifier.key isEqualToString:kAboutSpecifierKey] || [specifier.key isEqualToString:kAboutSpecifierKey] | [specifier.key isEqualToString:kFAQSpecifierKey] || [specifier.key isEqualToString:kPrivacyPolicySpecifierKey] || [specifier.key isEqualToString:kTermsOfUseSpecifierKey] || [specifier.key isEqualToString:kTutorialSpecifierKey]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = specifier.title;
	} else if ([specifier.key isEqualToString:kRegionSelectionSpecifierKey]) {
		// Prevent coalescing of region titles and flags by removing any existing subviews from the cell's content view
		[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

		// Get currently selected region
		Region *selectedRegion = [[RegionAdapter sharedInstance] getSelectedRegion];

		// Style and layout cell
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[cell.textLabel setText:specifier.title];


		UIImage *flag = [[PsiphonClientCommonLibraryHelpers imageFromCommonLibraryNamed:selectedRegion.flagResourceId] countryFlag];
		UIImageView *flagImage = [[UIImageView alloc] initWithImage:flag];

		// Size and place flag image. Text is sized and placed in viewDidLayoutSubviews
		if (isRTL) {
			flagImage.frame = CGRectMake(1, (cell.frame.size.height - flagImage.frame.size.height) / 2 , flag.size.width, flag.size.height);
		} else {
			flagImage.frame = CGRectMake(cell.contentView.frame.size.width - flagImage.frame.size.width, (cell.frame.size.height - flagImage.frame.size.height) / 2, flag.size.width, flag.size.height);
		}

		flagImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

		// Add flag and region name to detailTextLabel section of cell
		[cell.contentView addSubview:flagImage];
	}

	if ([links containsObject:specifier.key]) {
		cell.userInteractionEnabled = linksEnabled;
		cell.textLabel.enabled = linksEnabled;
		cell.detailTextLabel.enabled = linksEnabled;
	}
	return cell;
}

- (BOOL)isValidPort:(NSString *)port {
	NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	if ([port rangeOfCharacterFromSet:notDigits].location == NSNotFound)
	{
		NSInteger portNumber = [port integerValue];
		return (portNumber >= 1 && portNumber <= 65535);
	} else {
		return NO;
	}
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:kFeedbackSpecifierKey]) {
		FeedbackViewController *targetViewController = [[FeedbackViewController alloc] init];

		targetViewController.delegate = targetViewController;
		targetViewController.feedbackDelegate = self.settingsDelegate;
		targetViewController.file = specifier.file;
		targetViewController.settingsStore = self.settingsStore;
		targetViewController.showDoneButton = NO;
		targetViewController.showCreditsFooter = NO; // Does not reload the tableview (but next setters do it)
		targetViewController.title = specifier.title;

		IASK_IF_IOS7_OR_GREATER(targetViewController.view.tintColor = self.view.tintColor;)

		[self.navigationController pushViewController:targetViewController animated:YES];
	} else if ([specifier.key isEqualToString:kUpstreamProxyPort] || [specifier.key isEqualToString:kUpstreamProxyHostAddress]) {
		// Focus on textfield if cell pressed
		NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		if ([cell isKindOfClass:[IASKPSTextFieldSpecifierViewCell class]]) {
			IASKTextField *textField = ((IASKPSTextFieldSpecifierViewCell*)cell).textField;
			if ([textField.key isEqualToString:specifier.key]) {
				[textField becomeFirstResponder];
			}
		}
	} else if ([links containsObject:specifier.key]) {
		[self loadUrlForSpecifier:specifier.key];
	} else if ([specifier.key isEqualToString:kLogsSpecifierKey]) {
		LogViewController *vc = [[LogViewController alloc] init];
		vc.title = NSLocalizedStringWithDefaultValue(@"LOGS_TITLE", nil, [PsiphonClientCommonLibraryHelpers commonLibraryBundle], @"Logs", @"Title of screen that displays logs");
		[self.navigationController pushViewController:vc animated:YES];
	} else if ([specifier.key isEqualToString:kRegionSelectionSpecifierKey]) {
		RegionSelectionViewController *targetViewController = [[RegionSelectionViewController alloc] init];
		[self.navigationController pushViewController:targetViewController animated:YES];
	}
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:kForceReconnect]) {
		forceReconnectRequired = YES;
		[self dismiss:nil];
	}
}

- (void)loadUrlForSpecifier:(NSString *)key
{
	NSString *url;
	if ([key isEqualToString:kAboutSpecifierKey]) { // make this a hashmap
		url = NSLocalizedStringWithDefaultValue(@"ABOUT_PAGE_URL", nil, [PsiphonClientCommonLibraryHelpers commonLibraryBundle], @"https://psiphon.ca/en/about.html", @"External link to the about page. Please update this with the correct language specific link (if available) e.g. https://psiphon.ca/fr/about.html for french.");
	} else if ([key isEqualToString:kFAQSpecifierKey]) {
		url = NSLocalizedStringWithDefaultValue(@"FAQ_URL", nil, [PsiphonClientCommonLibraryHelpers commonLibraryBundle], @"https://psiphon.ca/en/faq.html", @"External link to the FAQ page. Please update this with the correct language specific link (if available) e.g. https://psiphon.ca/fr/faq.html for french.");
	} else if ([key isEqualToString:kPrivacyPolicySpecifierKey]) {
		url = NSLocalizedStringWithDefaultValue(@"PRIVACY_POLICY_URL", nil, [PsiphonClientCommonLibraryHelpers commonLibraryBundle], @"https://psiphon.ca/en/privacy.html", @"External link to the privacy policy page. Please update this with the correct language specific link (if available) e.g. https://psiphon.ca/fr/privacy.html for french.");
	} else if ([key isEqualToString:kTermsOfUseSpecifierKey]) {
		url = NSLocalizedStringWithDefaultValue(@"LICENSE_PAGE_URL", nil, [PsiphonClientCommonLibraryHelpers commonLibraryBundle], @"https://psiphon.ca/en/license.html", @"External link to the license page. Please update this with the correct language specific link (if available) e.g. https://psiphon.ca/fr/license.html for french.");
	}

	[self userPressedURL:[NSURL URLWithString:url]];
	[self settingsViewControllerDidEnd:nil];
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier
{
	if ([specifier.key isEqualToString:kLogsSpecifierKey]) {
#ifndef DEBUGLOGS
		return 0;
#endif
	}
	IASK_IF_IOS7_OR_GREATER
	(
	 NSDictionary *rowHeights = @{UIContentSizeCategoryExtraSmall: @(44),
								  UIContentSizeCategorySmall: @(44),
								  UIContentSizeCategoryMedium: @(44),
								  UIContentSizeCategoryLarge: @(44),
								  UIContentSizeCategoryExtraLarge: @(47)};
	 CGFloat rowHeight = (CGFloat)[rowHeights[UIApplication.sharedApplication.preferredContentSizeCategory] doubleValue];

	 rowHeight = rowHeight != 0 ? rowHeight : 51;

	 // Give multi-line cell more height per newline occurrence
	 NSError *error = NULL;
	 NSRegularExpression *newLineRegex = [NSRegularExpression regularExpressionWithPattern:@"\n" options:0 error:&error];

	 // Failed to compile/init regex
	 if (error != NULL)
	 return rowHeight;

	 NSUInteger numberOfNewLines = [newLineRegex numberOfMatchesInString:specifier.title options:0 range:NSMakeRange(0, [specifier.title length])];

	 return rowHeight + numberOfNewLines * 20;
	 );
	return 44;
}

- (void)IASKTextFieldDidEndEditing:(id)sender {
	IASKTextField *text = sender;
	[self.settingsStore setObject:[text text] forKey:[text key]];
	[[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:[text text]
																						   forKey:[text key]]];
}

- (void)settingDidChange:(NSNotification*)notification
{
	NSArray *upstreamProxyKeys = [NSArray arrayWithObjects:kUpstreamProxyHostAddress, kUpstreamProxyPort, kUseProxyAuthentication, nil];
	NSArray *proxyAuthenticationKeys = [NSArray arrayWithObjects:kProxyUsername, kProxyPassword, kProxyDomain, nil];

	NSString *fieldName = notification.userInfo.allKeys.firstObject;

	if ([fieldName isEqualToString:kDisableTimeouts]) {
		[self.tableView reloadData];
	} else if ([fieldName isEqual:kUseUpstreamProxy]) {
		BOOL upstreamProxyEnabled = (BOOL)[[notification.userInfo objectForKey:kUseUpstreamProxy] intValue];

		NSMutableSet *hiddenKeys = [NSMutableSet setWithSet:[self hiddenKeys]];

		if (upstreamProxyEnabled) {
			// Display proxy configuration fields
			for (NSString *key in upstreamProxyKeys) {
				[hiddenKeys removeObject:key];
			}

			BOOL useUpstreamProxyAuthentication = [[NSUserDefaults standardUserDefaults] boolForKey:kUseProxyAuthentication];

			if (useUpstreamProxyAuthentication) {
				// Display proxy authentication fields
				for (NSString *key in proxyAuthenticationKeys) {
					[hiddenKeys removeObject:key];
				}
			}

			[self setHiddenKeys:hiddenKeys animated:NO];
		} else {
			NSMutableSet *hiddenKeys = [NSMutableSet setWithArray:upstreamProxyKeys];
			[hiddenKeys addObjectsFromArray:proxyAuthenticationKeys];
			[self setHiddenKeys:hiddenKeys animated:NO];
		}
	} else if ([fieldName isEqual:kUseProxyAuthentication]) {
		// useProxyAuthentication toggled, show or hide proxy authentication fields
		BOOL enabled = (BOOL)[[notification.userInfo objectForKey:kUseProxyAuthentication] intValue];

		NSMutableSet *hiddenKeys = [NSMutableSet setWithSet:[self hiddenKeys]];

		if (enabled) {
			for (NSString *key in proxyAuthenticationKeys) {
				[hiddenKeys removeObject:key];
			}
		} else {
			for (NSString *key in proxyAuthenticationKeys) {
				[hiddenKeys addObject:key];
			}
		}
		[self setHiddenKeys:hiddenKeys animated:NO];
	} else if  ([fieldName isEqual:appLanguage]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[self settingsWillDismissWithForceReconnect:forceReconnectRequired];
		[self reloadAndOpenSettings];
	}
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender
{
	[self settingsWillDismissWithForceReconnect:forceReconnectRequired];
	// upon completion force connection state notification in case connection modal is
	// still blocking UI but needs to be dismissed
	[self.navigationController popViewControllerAnimated:NO];
	[self.navigationController dismissViewControllerAnimated:NO completion:^(){[self notifyPsiphonConnectionState];}];
}

- (void)updateAvailableRegions:(NSNotification*) notification {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
}

- (void)updateLinksState:(NSNotification*) notification {
	ConnectionState state = [[notification.userInfo objectForKey:kPsiphonConnectionState] unsignedIntegerValue];
	if(state == ConnectionStateConnected) {
		linksEnabled = true;
	} else {
		linksEnabled = false;
	}
	[self.tableView reloadData];
}

#pragma mark - SettingsViewControllerDelegate methods and helpers

- (BOOL)shouldEnableSettingsLinks {
	id<PsiphonSettingsViewControllerDelegate> strongDelegate = self.settingsDelegate;
	if ([strongDelegate respondsToSelector:@selector(shouldEnableSettingsLinks)]) {
		return [strongDelegate shouldEnableSettingsLinks];
	}

	return YES;
}

- (void)userPressedURL:(NSURL*)URL {
	id<PsiphonSettingsViewControllerDelegate> strongDelegate = self.settingsDelegate;
	if ([strongDelegate respondsToSelector:@selector(userPressedURL:)]) {
		[strongDelegate userPressedURL:URL];
	}
}

- (void)settingsWillDismissWithForceReconnect:(BOOL)forceReconnect {
	BOOL settingsRestartRequired = [self isSettingsRestartRequired];
	id<PsiphonSettingsViewControllerDelegate> strongDelegate = self.settingsDelegate;
	if ([strongDelegate respondsToSelector:@selector(settingsWillDismissWithForceReconnect:)]) {
		[strongDelegate settingsWillDismissWithForceReconnect:forceReconnect || settingsRestartRequired];
	}
}

- (void)reloadAndOpenSettings {
	id<PsiphonSettingsViewControllerDelegate> strongDelegate = self.settingsDelegate;
	if ([strongDelegate respondsToSelector:@selector(reloadAndOpenSettings)]) {
		[strongDelegate reloadAndOpenSettings];
	}
}

- (void)notifyPsiphonConnectionState {
	id<PsiphonSettingsViewControllerDelegate> strongDelegate = self.settingsDelegate;
	if ([strongDelegate respondsToSelector:@selector(notifyPsiphonConnectionState)]) {
		[strongDelegate notifyPsiphonConnectionState];
	}
}

- (BOOL)isSettingsRestartRequired {
	UpstreamProxySettings *proxySettings = [UpstreamProxySettings sharedInstance];

	if (_preferencesSnapshot) {
		// Check if "disable timeouts" has changed
		BOOL disableTimeouts = [[_preferencesSnapshot objectForKey:kDisableTimeouts] boolValue];

		if (disableTimeouts != [[NSUserDefaults standardUserDefaults] boolForKey:kDisableTimeouts]) {
			return YES;
		}

		// Check if the selected region has changed
		NSString *region = [_preferencesSnapshot objectForKey:kRegionSelectionSpecifierKey];

		if (!safeStringsEqual(region, [[RegionAdapter sharedInstance] getSelectedRegion].code)) {
			return YES;
		}

		// Check if "use proxy" has changed
		BOOL useUpstreamProxy = [[_preferencesSnapshot objectForKey:kUseUpstreamProxy] boolValue];

		if (useUpstreamProxy != [proxySettings getUseCustomProxySettings]) {
			return YES;
		}

		// No further checking if "use proxy" is off and has not
		// changed
		if (!useUpstreamProxy) {
			return NO;
		}

		// If "use proxy" is selected, check if host || port have changed
		NSString *hostAddress = [_preferencesSnapshot objectForKey:kUpstreamProxyHostAddress];
		NSString *proxyPort = [_preferencesSnapshot objectForKey:kUpstreamProxyPort];

		if (!safeStringsEqual(hostAddress, [proxySettings getCustomProxyHost]) || !safeStringsEqual(proxyPort, [proxySettings getCustomProxyPort])) {
			return YES;
		}

		// Check if "use proxy authentication" has changed
		BOOL useProxyAuthentication = [[_preferencesSnapshot objectForKey:kUseProxyAuthentication] boolValue];

		if (useProxyAuthentication != [proxySettings getUseProxyAuthentication]) {
			return YES;
		}

		// No further checking if "use proxy authentication" is off
		// and has not changed
		if (!useProxyAuthentication) {
			return NO;
		}

		// "use proxy authentication" is checked, check if
		// username || password || domain have changed
		NSString *username = [_preferencesSnapshot objectForKey:kProxyUsername];
		NSString *password = [_preferencesSnapshot objectForKey:kProxyPassword];
		NSString *domain = [_preferencesSnapshot objectForKey:kProxyDomain];

		if (!safeStringsEqual(username,[proxySettings getProxyUsername]) ||
			!safeStringsEqual(password, [proxySettings getProxyPassword]) ||
			!safeStringsEqual(domain, [proxySettings getProxyDomain])) {
			return YES;
		}
	}

	return NO;
}

@end
