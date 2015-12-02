//
//  WebService.h
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


//Launch link
#define BASE_URL                              @"http://actors-cam.com/api/"

//clients link
//#define BASE_URL                              @"http://ranosys.net/client/actorscam/api"

//testing link
//#define BASE_URL                              @"http://ranosys.net/client/actorscam/beta/api/"

@interface WebService : NSObject
@property(nonatomic,retain) NSString *usedWebservice;

@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
+ (id)sharedManager;


//Login screen method
- (void)userLogin:(NSString *)email Password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Register screen method
-(void)registerUser:(NSString *)mailId password:(NSString *)password name:(NSString*)name image:(UIImage *)image success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Forgot password method
-(void)forgotPassword:(NSString *)mailId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Change Password
-(void)changePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Add manager
- (void)addManager:(NSString *)managerName managerEmail:(NSString *)managerEmail category:(NSString *)category success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Manager Listing
- (void)managerListing:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Update Manager
- (void)updateManager:(NSString *)name managerEmail:(NSString *)managerEmail managerId:(NSString *)managerId category:(NSString *)category success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Delete Manager
- (void)deleteManager:(NSString *)managerId managerEmail:(NSString *)managerEmail success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Get Profile
- (void)getprofile:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//update profile
-(void)updateprofile:(NSString *)name image:(UIImage *)image success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
@end
