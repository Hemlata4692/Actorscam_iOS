//
//  WebService.m
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "WebService.h"
#import "NullValueChecker.h"
#import "LoginViewController.h"
#import "Internet.h"
#define kUrlLogin                       @"login"
#define kUrlRegister                    @"register"
#define kUrlForgotPassword              @"forgotpassword"
#define kUrlChangePassword              @"changepassword"
#define kUrlAddManager                  @"addmanager"
#define kUrlManagerListing              @"getmanagerlisting"
#define kUrlUpdateManager               @"updatemanager"
#define kUrlDeleteManager               @"deletemanager"
#define kUrlGetprofile                  @"getprofile"
#define kUrlUpdateprofile               @"updateprofile"

@implementation WebService
@synthesize manager;
@synthesize usedWebservice;

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
        usedWebservice = @"";
    }
    return self;
}

#pragma mark - AFNetworking method
- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    Internet *internet=[[Internet alloc] init];
    if ([internet start])
    {
        [myDelegate StopIndicator];
        NSError *error = nil;
        failure(error);
    }
    else
    {
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         [myDelegate StopIndicator];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [myDelegate StopIndicator];
        failure(error);
        usedWebservice = @"";
        if ([error.localizedDescription isEqualToString:@"The request timed out."]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"The request timed out." changeTextLanguage:@"The request timed out."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
        }
        else if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"The Internet connection appears to be offline." changeTextLanguage:@"The Internet connection appears to be offline."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else if ([error.localizedDescription isEqualToString:@"The network connection was lost."]){
           
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"The network connection was lost." changeTextLanguage:@"The network connection was lost."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
        
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:error.localizedDescription delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    }
}

- (void)postImage:(NSString *)path parameters:(NSDictionary *)parameters image:(UIImage *)image success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    Internet *internet=[[Internet alloc] init];
    if ([internet start])
    {
        [myDelegate StopIndicator];
        NSError *error = nil;
        failure(error);
    }
    else
    {

    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  //  NSLog(@"path: %@, %@", path, parameters);
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    [manager POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFormData:imageData name:@"image.png"];
        [formData appendPartWithFileData:imageData name:@"files" fileName:@"files.jpg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myDelegate StopIndicator];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myDelegate StopIndicator];
        failure(error);
        usedWebservice = @"";
        if ([error.localizedDescription isEqualToString:@"The request timed out."]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"The request timed out." changeTextLanguage:@"The request timed out."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
        }
        else if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"The Internet connection appears to be offline." changeTextLanguage:@"The Internet connection appears to be offline."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else if ([error.localizedDescription isEqualToString:@"The network connection was lost."]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"The network connection was lost." changeTextLanguage:@"The network connection was lost."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:error.localizedDescription delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    }
    
    }

- (BOOL)isStatusOK:(id)responseObject {
    NSNumber *number = responseObject[@"isSuccess"];
    NSString *msg;
    switch (number.integerValue)
    {
        case 0:
        {
            usedWebservice = @"";
            msg = responseObject[@"message"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[msg changeTextLanguage:msg] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles: nil];
            [alert show];
            return NO;
        }

        case 1:
            return YES;
            break;
            
        case 2:
        {
            msg = responseObject[@"message"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Your account has been deactivated by Actor CAM." changeTextLanguage:@"Your account has been deactivated by Actor CAM."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles: nil];
            alert.tag=2;
            [alert show];

        }
            return NO;
            break;
        default: {
            usedWebservice = @"";
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:responseObject[@"message"] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles: nil];
            [alert show];
            
        }
            return NO;
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==2 && buttonIndex==0)
    {
        if (!([usedWebservice isEqualToString:kUrlLogin] || [usedWebservice isEqualToString:kUrlRegister] || [usedWebservice isEqualToString:kUrlForgotPassword])) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [myDelegate.window setRootViewController:objReveal];
            [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
            [myDelegate.window makeKeyAndVisible];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"UserId"];
            [defaults removeObjectForKey:@"actorName"];
            [defaults removeObjectForKey:@"EmailId"];
            [defaults synchronize];
        }
        
    }
    usedWebservice = @"";
}
#pragma mark - end

#pragma mark- Login Module
//Login
- (void)userLogin:(NSString *)email Password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"email":email,@"password":password};
    usedWebservice = kUrlLogin;
    [self post:kUrlLogin parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Register
-(void)registerUser:(NSString *)mailId password:(NSString *)password name:(NSString*)name image:(UIImage *)image success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"email":mailId,@"password":password,@"username":name};
     usedWebservice = kUrlRegister;
    [self postImage:kUrlRegister parameters:requestDict image:image success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         //  NSLog(@"Register User Response%@", responseObject);
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Forgot Password
-(void)forgotPassword:(NSString *)mailId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"email":mailId};
    usedWebservice = kUrlForgotPassword;
    [self post:kUrlForgotPassword parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Change Password
-(void)changePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{ @"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"oldPassword":oldPassword, @"newPassword":newPassword};
    usedWebservice = kUrlChangePassword;
    [self post:kUrlChangePassword parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Manager module
//Add manager
- (void)addManager:(NSString *)managerName managerEmail:(NSString *)managerEmail category:(NSString *)category  success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"managerName":managerName,@"managerEmail":managerEmail,@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"category":category};
    usedWebservice = kUrlAddManager;
    [self post:kUrlAddManager parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Manager Listing
- (void)managerListing:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"category":@""};
    usedWebservice = kUrlManagerListing;
    [self post:kUrlManagerListing parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Update Manager
- (void)updateManager:(NSString *)name managerEmail:(NSString *)managerEmail managerId:(NSString *)managerId category:(NSString *)category success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    
    NSDictionary *requestDict = @{@"managerName":name,@"managerEmail":managerEmail,@"managerId":managerId,@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"category":category};
    usedWebservice = kUrlUpdateManager;
    [self post:kUrlUpdateManager parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//Delete Manager
- (void)deleteManager:(NSString *)managerId managerEmail:(NSString *)managerEmail success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"managerId":managerId,@"managerEmail":managerEmail ,@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    usedWebservice = kUrlDeleteManager;
    [self post:kUrlDeleteManager parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Profile Module
//Get Profile
- (void)getprofile:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    usedWebservice = kUrlGetprofile;
    [self post:kUrlGetprofile parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         } else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}

//update profile
-(void)updateprofile:(NSString *)name image:(UIImage *)image success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"username":name};
    usedWebservice = kUrlUpdateprofile;
    [self postImage:kUrlUpdateprofile parameters:requestDict image:image success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         
         if([self isStatusOK:responseObject])
         {
             success(responseObject);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

@end
