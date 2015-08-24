//
//  ImagePreviewViewController.m
//  ActorsCam
//
//  Created by Ranosys on 24/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ImagePreviewViewController.h"

@interface ImagePreviewViewController (){
    NSMutableArray *imageArray;
    int selectedImage;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewView;
@property (weak, nonatomic) IBOutlet UICollectionView *previewCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectManager;
@property (weak, nonatomic) IBOutlet UITextField *managerName;
@property (weak, nonatomic) IBOutlet UIButton *sendImageButton;
@property (weak, nonatomic) IBOutlet UILabel *noManager;
@end

@implementation ImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    imageArray = [NSMutableArray arrayWithObjects:
                   @"modal1.jpeg", @"modal2.jpeg",
                   @"modal3.jpeg", @"modal4.jpeg", @"modal5.jpeg", nil];
//    if (imageArray.count) {
        selectedImage = 0;
//    }
//    else{
//        selectedImage = -1;
//    }
    
    _imagePreviewView.image = [UIImage imageNamed:[imageArray objectAtIndex:selectedImage]];
    _imagePreviewView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [_imagePreviewView addGestureRecognizer:swipeLeft];
    [_imagePreviewView addGestureRecognizer:swipeRight];

    
    
    // Do any additional setup after loading the view.
}

- (void)addAnimationPresentToView:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

- (void)addAnimationPresentToViewOut:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}


- (void)swipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if(sender.direction==UISwipeGestureRecognizerDirectionLeft){
        NSLog(@"right");
        
        selectedImage++;
        if(selectedImage<imageArray.count){
            
            UIImageView *moveIMageView = _imagePreviewView;
            [self addAnimationPresentToView:moveIMageView];
            _imagePreviewView.image = [UIImage imageNamed:[imageArray objectAtIndex:selectedImage]];
            [self.previewCollectionView reloadData];
        }
        else{
            selectedImage=imageArray.count-1;
        }
    }
    else{
        NSLog(@"left");
        selectedImage--;
        if(selectedImage>=0){
            UIImageView *moveIMageView = _imagePreviewView;
            [self addAnimationPresentToViewOut:moveIMageView];
            _imagePreviewView.image = [UIImage imageNamed:[imageArray objectAtIndex:selectedImage]];
            [self.previewCollectionView reloadData];
        }
        else{
            selectedImage=0;
        }
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Preview";
}

#pragma mark - Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
 
    return imageArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell = [collectionView1
                                    dequeueReusableCellWithReuseIdentifier:@"myCell"
                                    forIndexPath:indexPath];
    
    UIImageView *image = (UIImageView*)[myCell viewWithTag:1];
    image.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
    
    if (selectedImage == indexPath.row) {
        image.layer.borderColor = [UIColor blueColor].CGColor;
        image.layer.borderWidth = 1;
    }
    else{
        image.layer.borderColor = [UIColor clearColor].CGColor;
        image.layer.borderWidth = 1;
    }
    return myCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *image = (UIImageView*)[cell viewWithTag:1];
    image.layer.borderColor = [UIColor blueColor].CGColor;
    image.layer.borderWidth = 1;
    selectedImage = indexPath.row;
     _imagePreviewView.image = [UIImage imageNamed:[imageArray objectAtIndex:selectedImage]];
    for (int i=0; i<imageArray.count; i++) {
        if (i!=indexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UICollectionViewCell *cell1 = [collectionView cellForItemAtIndexPath:newIndexPath];
            UIImageView *image = (UIImageView*)[cell1 viewWithTag:1];
            image.layer.borderColor = [UIColor clearColor].CGColor;
            image.layer.borderWidth = 1;
        }
    }
    
}

#pragma mark - end

- (IBAction)selectManagerAction:(UIButton *)sender {
}

- (IBAction)deleteImageAction:(UIButton *)sender {
}

- (IBAction)sendImageButtonAction:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
