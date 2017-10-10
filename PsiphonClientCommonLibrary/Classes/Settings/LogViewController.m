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

@implementation LogViewController {
	UITableView *table;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	timerLock = [[NSLock alloc] init];

	table = [[UITableView alloc] init];
	table.dataSource = self;
	table.delegate = self;
	//    table.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	//    table.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	table.estimatedRowHeight = 60;
	table.rowHeight = UITableViewAutomaticDimension;
	
	[self.view addSubview:table];
	
	// setup autolayout
	table.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:table
														  attribute:NSLayoutAttributeLeft
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeLeft
														 multiplier:1.f
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:table
														  attribute:NSLayoutAttributeRight
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeRight
														 multiplier:1.f
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:table
														  attribute:NSLayoutAttributeTop
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeTop
														 multiplier:1.f
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:table
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

#pragma mark - UITableView delegate methods

// Scroll to bottom of UITableView
-(void)scrollToBottom {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.diagnosticEntries count] > 0) {
            NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:[self.diagnosticEntries count] - 1 inSection:0];
            [table selectRowAtIndexPath:myIndexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
        }
    });
}

- (void)onDataChanged {
    [table reloadData];
    [self scrollToBottom];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.diagnosticEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DiagnosticEntry *entry = self.diagnosticEntries[indexPath.row];

	NSString *statusEntryForDisplay = [NSString stringWithFormat:@"%@ %@",
	[entry getTimestampForDisplay], [entry message]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:statusEntryForDisplay];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:statusEntryForDisplay];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.text = statusEntryForDisplay;
	
	return cell;
}

@end
