//
//  NetworkStatusChangeNotifier.h
//  Note Safe
//
//  Created by Harrison White on 5/7/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#define kNetworkStatusDidChangeNotification	@"kNetworkStatusDidChangeNotification"

enum {
	kNetworkStatusNotConnected = 0,
	kNetworkStatusConnectedViaWiFi,
	kNetworkStatusConnectedViaWWAN
};
typedef NSUInteger kNetworkStatus;

@interface NetworkStatusChangeNotifier : NSObject {
	BOOL localWiFiRef;
    SCNetworkReachabilityRef networkReachabilityRef;
}

+ (NetworkStatusChangeNotifier *)defaultNotifier;
+ (NetworkStatusChangeNotifier *)notifierWithAddress:(const struct sockaddr_in *)hostAddress;
- (BOOL)startNotifier;
- (void)stopNotifier;
- (kNetworkStatus)currentNetworkStatus;
- (kNetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags;
- (kNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags;

@end
