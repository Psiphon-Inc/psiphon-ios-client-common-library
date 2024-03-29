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


#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"

@class FeedbackViewController;

@protocol FeedbackViewControllerDelegate <NSObject>

- (void)userSubmittedFeedback:(NSInteger)selectedThumbIndex
                     comments:(NSString*)comments
                        email:(NSString*)email
            uploadDiagnostics:(BOOL)uploadDiagnostics
               viewController:(FeedbackViewController*)viewController;

- (void)userPressedURL:(NSURL*)URL;

@optional

- (void)feedbackViewControllerWillDismiss:(FeedbackViewController*)viewController;

@end

@interface FeedbackViewController : IASKAppSettingsViewController <UITableViewDelegate, IASKSettingsDelegate, UITextViewDelegate>
@property (weak, nonatomic) id<FeedbackViewControllerDelegate> feedbackDelegate;

@property (strong, nonatomic, nullable) NSDictionary* associatedData;

@end
