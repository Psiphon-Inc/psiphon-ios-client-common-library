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

#import <Foundation/Foundation.h>
#import "PsiphonData.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeedbackUpload : NSObject
+ (NSString*)generateFeedbackId;
+ (NSString*_Nullable)generateFeedbackJSON:(NSInteger)thumbIndex
                                 buildInfo:(NSString*_Nullable)buildInfo
                                  comments:(NSString*_Nullable)comments
                                     email:(NSString*_Nullable)email
                        sendDiagnosticInfo:(BOOL)sendDiagnosticInfo
                         withPsiphonConfig:(NSString*)psiphonConfig
                        withClientPlatform:(NSString*_Nullable)clientPlatform
                        withConnectionType:(NSString*_Nullable)connectionType
                              isJailbroken:(BOOL)isJailbroken
                         diagnosticEntries:(NSArray<DiagnosticEntry *>*_Nullable)diagnosticEntries
                                     error:(NSError*_Nullable*)outError;
@end

NS_ASSUME_NONNULL_END
