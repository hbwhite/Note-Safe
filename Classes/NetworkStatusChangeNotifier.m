//
//  NetworkStatusChangeNotifier.m
//  Note Safe
//
//  Created by Harrison White on 5/7/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "NetworkStatusChangeNotifier.h"


@implementation NetworkStatusChangeNotifier

static void NetworkStatusChangeNotifierCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
	NetworkStatusChangeNotifier *notificationObject = (NetworkStatusChangeNotifier *)info;
	[[NSNotificationCenter defaultCenter]postNotificationName:kNetworkStatusDidChangeNotification object:notificationObject];
}

+ (NetworkStatusChangeNotifier *)defaultNotifier {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	return [self notifierWithAddress:&zeroAddress];
}

+ (NetworkStatusChangeNotifier *)notifierWithAddress:(const struct sockaddr_in *)hostAddress {
	SCNetworkReachabilityRef networkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
	NetworkStatusChangeNotifier *returnValue = NULL;
	if (networkReachability != NULL) {
		returnValue = [[[self alloc]init]autorelease];
		if (returnValue != NULL) {
			returnValue->networkReachabilityRef = networkReachability;
			returnValue->localWiFiRef = NO;
		}
	}
	return returnValue;
}

- (BOOL)startNotifier {
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = { 0, self, NULL, NULL, NULL };
	if (SCNetworkReachabilitySetCallback(networkReachabilityRef, NetworkStatusChangeNotifierCallback, &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(networkReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
			returnValue = YES;
		}
	}
	return returnValue;
}

- (void)stopNotifier {
	if (networkReachabilityRef != NULL) {
		SCNetworkReachabilityUnscheduleFromRunLoop(networkReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}

- (kNetworkStatus)currentNetworkStatus {
	kNetworkStatus returnValue = kNetworkStatusNotConnected;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(networkReachabilityRef, &flags)) {
		if (localWiFiRef) {
			returnValue = [self localWiFiStatusForFlags:flags];
		}
		else {
			returnValue = [self networkStatusForFlags:flags];
		}
	}
	return returnValue;
}

- (kNetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags {
	BOOL returnValue = kNetworkStatusNotConnected;
	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
		returnValue = kNetworkStatusConnectedViaWiFi;
	}
	return returnValue;
}

- (kNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		return kNetworkStatusNotConnected;
	}
	BOOL returnValue = kNetworkStatusNotConnected;
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		returnValue = kNetworkStatusConnectedViaWiFi;
	}
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
		 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
		
		if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
			returnValue = kNetworkStatusConnectedViaWiFi;
		}
	}
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		returnValue = kNetworkStatusConnectedViaWWAN;
	}
	return returnValue;
}

- (void)dealloc {
	[self stopNotifier];
	if (networkReachabilityRef != NULL) {
		CFRelease(networkReachabilityRef);
	}
	[super dealloc];
}

@end
