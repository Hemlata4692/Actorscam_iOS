//
//  WebService.m
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "WebService.h"


@implementation WebService
@synthesize manager;

#pragma mark - AFNetworking method
+ (id)sharedManager
{
    static WebService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init
{
    if (self = [super init])
    {
        manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    }
    return self;
}

- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // [myDelegate StopIndicator];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       // [myDelegate StopIndicator];
        failure(error);
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
}



- (BOOL)isStatusOK:(id)responseObject {
    NSNumber *number = responseObject[@"IsSuccess"];
    
    switch (number.integerValue) {
        case 1:
            return YES;
            break;
        case 0: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:responseObject[@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
            return NO;
            break;
        default: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:responseObject[@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
            return NO;
            break;
    }
}
#pragma mark - end

@end
