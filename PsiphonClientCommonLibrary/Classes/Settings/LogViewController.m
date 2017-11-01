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

#import "LogViewController.h"

@implementation LogViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.diagnosticEntries = [[NSMutableArray alloc] init];

	self.tableView = [[UITableView alloc] init];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	//    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	self.tableView.estimatedRowHeight = 60;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	[self.view addSubview:self.tableView];
	
	// setup autolayout
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
														  attribute:NSLayoutAttributeLeft
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeLeft
														 multiplier:1.f
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
														  attribute:NSLayoutAttributeRight
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeRight
														 multiplier:1.f
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
														  attribute:NSLayoutAttributeTop
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeTop
														 multiplier:1.f
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeBottom
														 multiplier:1.f
														   constant:0]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

#pragma mark - Helper methods

// Scroll to bottom of UITableView
-(void)scrollToBottom {
	if ([self.diagnosticEntries count] > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.diagnosticEntries count] - 1 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
	}
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.diagnosticEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DiagnosticEntry *entry = self.diagnosticEntries[indexPath.row];

	NSMutableAttributedString *attrTextForDisplay = [[NSMutableAttributedString alloc]
	  initWithString:[NSString stringWithFormat:@"%@  ", [entry getTimestampForDisplay]]
		  attributes:@{NSForegroundColorAttributeName: [UIColor blueColor],
					   NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:10.f]}];

	NSDictionary *emoNoticeMapping = @{
		@"Tunnels: {\"count\":1}": @"🚀",
		@"Homepage": @"🏡",
		@"Info": @"ℹ️",
		@"Alert": @"🚨",
		@"ActiveTunnel": @"🚇"
	};

	NSDictionary *messageAttr = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12.f]};
	NSString *displayMessage = [entry message];

	for (NSString *key in emoNoticeMapping) {
		if (([[entry message] length] >= [key length])
			&& ([[[entry message] substringToIndex:[key length]] isEqualToString:key])) {
			displayMessage = [NSString stringWithFormat:@"%@ %@", emoNoticeMapping[key], [entry message]];
		}
	}

	NSMutableAttributedString *attrEntryMessage = [[NSMutableAttributedString alloc]
	  initWithString:displayMessage
		  attributes:messageAttr];

	[attrTextForDisplay appendAttributedString:attrEntryMessage];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusableCell"];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reusableCell"];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.attributedText = attrTextForDisplay;

	return cell;
}

@end
