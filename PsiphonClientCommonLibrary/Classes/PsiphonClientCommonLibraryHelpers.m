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

#import "PsiphonClientCommonLibraryConstants.h"
#import "PsiphonClientCommonLibraryHelpers.h"

@implementation PsiphonClientCommonLibraryHelpers

+ (NSBundle*)commonLibraryBundle {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.classForCoder];
    NSString *bundlePath = [frameworkBundle pathForResource:kPsiphonClientCommonLibraryBundleName ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	return bundle;
}

// From http://blog.flaviocaetano.com/post/cocoapods-and-resource_bundles/
+ (UIImage*)imageFromCommonLibraryNamed:(NSString*)imageName {
	return [UIImage imageNamed:imageName inBundle:[PsiphonClientCommonLibraryHelpers commonLibraryBundle] compatibleWithTraitCollection:nil];
}

+ (void)initializeDefaultsFor:(NSString*)plist {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSString *plistPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"InAppSettings.bundle"] stringByAppendingPathComponent:plist];
	NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];

	for (NSDictionary *pref in [settingsDictionary objectForKey:@"PreferenceSpecifiers"]) {
		NSString *key = [pref objectForKey:@"Key"];
		if (key == nil)
			continue;

		if ([userDefaults objectForKey:key] == NULL) {
			NSObject *val = [pref objectForKey:@"DefaultValue"];
			if (val == nil)
				continue;

			[userDefaults setObject:val forKey:key];
#ifdef TRACE
			NSLog(@"initialized default preference for %@ to %@", key, val);
#endif
		}
	}
	[userDefaults synchronize];
}

+ (NSString * _Nullable)getPsiphonConfigForFeedbackUpload {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *bundledConfigPath = [[[NSBundle mainBundle] resourcePath]
								   stringByAppendingPathComponent:@"psiphon_config"];

	if (![fileManager fileExistsAtPath:bundledConfigPath]) {
		NSLog(@"Config file not found for feedback upload.");
		return @"";
	}

	// Read in psiphon_config JSON
	NSData *jsonData = [fileManager contentsAtPath:bundledConfigPath];
	NSError *err = nil;
	NSDictionary *readOnly = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];

	if (err) {
		NSLog(@"Failed to parse config JSON for feedback upload: %@", err.description);
		return @"";
	}

	NSMutableDictionary *mutableConfigCopy = [readOnly mutableCopy];
	jsonData  = [NSJSONSerialization dataWithJSONObject:mutableConfigCopy
												options:0 error:&err];

	if (err) {
		NSLog(@"Failed to create JSON data from config object for feedback upload: %@", err.description);
		abort();
	}

	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
