//
//  PsiphonClientCommonLibraryConstants.h
//  PsiphonClientCommonLibrary
//
//  Created by Miro Kuratczyk on 2017-08-28.
//

#ifndef PsiphonClientCommonLibraryConstants_h
#define PsiphonClientCommonLibraryConstants_h

#define kPsiphonConnectionState @"kPsiphonConnectionState"
#define kPsiphonConnectionStateNotification @"kPsiphonConnectionStateNotification"
#define kPsiphonClientCommonLibraryBundleName @"PsiphonClientCommonLibrary"

/* Psiphon connection states */
typedef NS_ENUM(NSInteger, ConnectionState)
{
	ConnectionStateDisconnected,
	ConnectionStateConnecting,
	ConnectionStateConnected,
	ConnectionStateWaitingForNetwork
};

#endif /* PsiphonClientCommonLibraryConstants_h */
