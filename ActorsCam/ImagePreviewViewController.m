//
//  ImagePreviewViewController.m
//  ActorsCam
//
//  Created by Ranosys on 24/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ImagePreviewViewController.h"

@interface ImagePreviewViewController (){
    NSMutableArray *pickerArray;
    int selectedImage;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewView;
@property (weak, nonatomic) IBOutlet UICollectionView *previewCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectManager;
@property (weak, nonatomic) IBOutlet UITextField *managerName;
@property (weak, nonatomic) IBOutlet UIButton *sendImageButton;
@property (weak, nonatomic) IBOutlet UILabel *noManager;
@property (weak, nonatomic) IBOutlet UIView *selectManagerView;
@property (weak, nonatomic) IBOutlet UIPickerView *managerListPickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarDone;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation ImagePreviewViewController
@synthesize imageArray,customCameraVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    imageArray = [NSMutableArray arrayWithObjects:
//                   @"modal1.jpeg", @"modal2.jpeg",
//                   @"modal3.jpeg", @"modal4.jpeg", @"modal5.jpeg", nil];
    pickerArray = [NSMutableArray arrayWithObjects:
                  @"Sumeet", @"Shiven",
                  @"Vikas", @"Priyavrat", nil];

    
    selectedImage = 0;
//    _imagePreviewView.image = [UIImage imageNamed:[imageArray objectAtIndex:selectedImage]];
    _imagePreviewView.image = [imageArray objectAtIndex:selectedImage];
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    _selectManagerView.hidden = NO;
    _noManager.hidden = YES;
    _managerListPickerView.hidden = YES;
    _toolBar.hidden = YES;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Preview";
    
    /* call webservice
     if i have bot manager list so
        _selectManagerView.hidden = YES;
        _noManager.hidden = NO;
     else
        _selectManagerView.hidden = NO;
        _noManager.hidden = YES;
     */
    
//    [myDelegate ShowIndicator];
//    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
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
    image.image = [imageArray objectAtIndex:indexPath.row];
    
    if (selectedImage == indexPath.row) {
        image.layer.borderColor = [UIColor blueColor].CGColor;
        image.layer.borderWidth = 2;
    }
    else{
        image.layer.borderColor = [UIColor clearColor].CGColor;
        image.layer.borderWidth = 2;
    }
    return myCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *image = (UIImageView*)[cell viewWithTag:1];
    image.layer.borderColor = [UIColor blueColor].CGColor;
    image.layer.borderWidth = 2;
    selectedImage = (int)indexPath.row;
     _imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
    for (int i=0; i<imageArray.count; i++) {
        if (i!=indexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UICollectionViewCell *cell1 = [collectionView cellForItemAtIndexPath:newIndexPath];
            UIImageView *image = (UIImageView*)[cell1 viewWithTag:1];
            image.layer.borderColor = [UIColor clearColor].CGColor;
            image.layer.borderWidth = 2;
        }
    }
    
}

//-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
//    for (UICollectionViewCell *cell in [self.previewCollectionView visibleCells]) {
//        NSIndexPath *indexPath = [self.previewCollectionView indexPathForCell:cell];
//        NSLog(@"%@",indexPath);
//    }
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//}
#pragma mark - end

- (IBAction)selectManagerAction:(UIButton *)sender {
    [_scrollView setContentOffset:CGPointMake(0, _managerName.frame.origin.y + 150) animated:YES];
    _managerListPickerView.hidden = NO;
    _toolBar.hidden = NO;
}

- (IBAction)deleteImageAction:(UIButton *)sender {
    [imageArray removeObjectAtIndex:selectedImage];
    selectedImage = 0;
    if (imageArray.count!=0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedImage inSection:0];
        [self.previewCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        _imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
        [_previewCollectionView reloadData];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)sendImageButtonAction:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISwipeGesture handler
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
            
//            NSArray* cv = [self.previewCollectionView visibleCells];
            BOOL flag = NO;
            for (UICollectionViewCell *cell in [self.previewCollectionView visibleCells]) {
                NSIndexPath *indexPath = [self.previewCollectionView indexPathForCell:cell];
                if (indexPath.row != selectedImage) {
                    flag = YES;
                }
                else{
                    flag = NO;
                    break;
                }
                NSLog(@"%@",indexPath);
            }
            
            if (flag) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedImage inSection:0];
                [self.previewCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }

            UIImageView *moveIMageView = _imagePreviewView;
            [self addAnimationPresentToView:moveIMageView];
            _imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
            [self.previewCollectionView reloadData];
        }
        else{
            selectedImage = (int)imageArray.count-1;
        }
    }
    else{
        NSLog(@"left");
        selectedImage--;
        if(selectedImage>=0){
            
            BOOL flag = NO;
            for (UICollectionViewCell *cell in [self.previewCollectionView visibleCells]) {
                NSIndexPath *indexPath = [self.previewCollectionView indexPathForCell:cell];
                if (indexPath.row != selectedImage) {
                    flag = YES;
                }
                else{
                    flag = NO;
                    break;
                }
                NSLog(@"%@",indexPath);
            }
            
            if (flag) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedImage inSection:0];
                [self.previewCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }
            
            UIImageView *moveIMageView = _imagePreviewView;
            [self addAnimationPresentToViewOut:moveIMageView];
            _imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
            [self.previewCollectionView reloadData];
        }
        else{
            selectedImage=0;
        }
        
    }
    
}
#pragma mark - end

#pragma mark - Pickerview Delegate Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerArray objectAtIndex:row];
}
#pragma mark - end

#pragma mark - Toolbar Done Action
- (IBAction)DoneAction:(UIBarButtonItem *)sender {
    NSInteger index = [_managerListPickerView selectedRowInComponent:0];
    _managerName.text=[pickerArray objectAtIndex:index];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    _managerListPickerView.hidden = YES;
    _toolBar.hidden = YES;
    
}
#pragma mark - end


#pragma mark - Manager Listing method
-(void)managerListing
{
    [[WebService sharedManager] managerListing:^(id responseObject) {
        NSLog(@"response is %@",responseObject);
        [myDelegate StopIndicator];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
     customCameraVC.imageArray = [imageArray mutableCopy];
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
