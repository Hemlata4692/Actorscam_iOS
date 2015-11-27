//
//  Internet.m
//  RKPharma
//
//  Created by shiv vaishnav on 16/05/13.
//  Copyright (c) 2013 shivendra@ranosys.com. All rights reserved.
//

#import "Reachability.h"
#import "Internet.h"

@implementation Internet
{
    Reachability *reachability;
}
-(BOOL) start 
{
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
     NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
     if(remoteHostStatus == NotReachable) 
    {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[@"Connection Error" changeTextLanguage:@"Connection Error"] message:[@"Please check your internet connection." changeTextLanguage:@"Please check your internet connection."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
       [alert show];
    
        return YES;
    }
    else
    {
        return NO;
    }
    
}
@end
