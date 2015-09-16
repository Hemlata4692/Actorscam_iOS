//
//  ImagePreviewViewController.h
//  ActorsCam
//
//  Created by Ranosys on 24/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCameraViewController.h"

@interface ImagePreviewViewController : UIViewController
@property(nonatomic,retain) NSMutableArray *imageArray;
@property(nonatomic,retain) CustomCameraViewController *customCameraVC;

@end
