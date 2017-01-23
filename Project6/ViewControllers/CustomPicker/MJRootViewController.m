//
//  MJViewController.m
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import "MJRootViewController.h"
#import "MJCollectionViewCell.h"
#import "Public.h"

@interface MJRootViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UICollectionView *parallaxCollectionView;
@property (nonatomic, strong) NSMutableArray* images;

@end

@implementation MJRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = COLOR_BACKGROUND;
    self.title = @"Picker";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.itemSize = CGSizeMake(self.view.width, self.view.width/4.0*3.0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.parallaxCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64) collectionViewLayout:layout];
    [self.parallaxCollectionView registerClass:[MJCollectionViewCell class] forCellWithReuseIdentifier:@"MJCell"];
    
    self.parallaxCollectionView.delegate = self;
    self.parallaxCollectionView.dataSource = self;
    // Fill image array with images
    PFQuery *query = [PFQuery queryWithClassName:PF_PHOTO_GALLERY_CLASS_NAME];
    [query whereKey:PF_PHOTO_USER equalTo:[PFUser currentUser]];
    self.images = [NSMutableArray array];
    [[KIProgressViewManager manager] showProgressOnView:self.view];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[KIProgressViewManager manager] hideProgressView];
        if (!error) {
            for(PFObject *object in objects) {
                [self.images addObject:object[PF_PHOTO_PICTURE]];
            }
            [self.parallaxCollectionView reloadData];

        }
    }];
    [self.view addSubview:self.parallaxCollectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MJCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MJCell" forIndexPath:indexPath];
    
    //get image name and assign
    NSString* imageName = [self.images objectAtIndex:indexPath.item];
    [cell setImage:imageName];
    //set offset accordingly
    CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);

    return cell;
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(MJCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
        CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* imageName = [self.images objectAtIndex:indexPath.item];
    if(self.delegate && [self.delegate respondsToSelector:@selector(photoSelected:)]) {
        [self.delegate photoSelected:imageName];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
