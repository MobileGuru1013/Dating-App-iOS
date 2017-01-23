//
//  PhototasticViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "PhototasticViewController.h"
#import "KASlideShow.h"
#import "DraggableView.h"

@interface PhototasticViewController () <UIAlertViewDelegate>
{
    KASlideShow *slideView;
    NSArray *photoArray;
    
    UIImageView *photoView;
    
    int cardsLoadedIndex;
    
    UILabel *lblRate;
    
    int myTestPhoto_Number;
    
    UILabel *lblNoMore;
    
    UIButton *flagBtn;
    
    UILabel *lblIntro2;
    
    UILabel *lblIntroduction;
    UILabel *lblIntro;
    
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)

    float CARD_HEIGHT;
    float CARD_WIDTH;
}
@end

@implementation PhototasticViewController
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CARD_HEIGHT = pubWidth;
    CARD_WIDTH = pubWidth;
    
    exampleCardLabels = [[NSArray alloc]initWithObjects:@"first",@"second",@"third",@"fourth",@"last", nil]; //%%% placeholder for card-specific information
    loadedCards = [[NSMutableArray alloc] init];
    allCards = [[NSMutableArray alloc] init];
    cardsLoadedIndex = 0;
    
    lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, self.view.width-20, 32)];
    lblIntroduction.textAlignment = NSTextAlignmentLeft;
    lblIntroduction.textColor = COLOR_IN_DARK_GRAY;
    lblIntroduction.font = [UIFont systemFontOfSize:12];
    lblIntroduction.numberOfLines = 2;
    lblIntroduction.text = @"(Phototastic is completely anoymous so she will not know who rated her)";
    lblIntroduction.hidden = YES;
    [self.view addSubview:lblIntroduction];

    
    lblIntro = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pubWidth, 40)];
    lblIntro.text = @"Would you go on a date with...?";
    lblIntro.font = [UIFont boldSystemFontOfSize:17];
    lblIntro.textColor = COLOR_IN_BLACK;
    lblIntro.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:lblIntro];
    
    UIButton *btn_up = [[UIButton alloc] initWithFrame:CGRectMake(0, lblIntro.bottom, pubWidth, 40)];
    [btn_up setBackgroundColor:[UIColor colorWithRed:184.0/255.0 green:81.0/255.0 blue:179.0/255.0 alpha:1.0]];
    [btn_up setImage:[[UIImage imageNamed:@"like_rate.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_up setTintColor:[UIColor whiteColor]];
    [btn_up setTitle:@"  Swipe Right for Yes" forState:UIControlStateNormal];
    [btn_up setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_up.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, btn_up.bottom-20, self.view.width, self.view.width)];
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.clipsToBounds = YES;
    photoView.userInteractionEnabled = YES;
    
    [self.view addSubview:photoView];

    UIButton *btn_down = [[UIButton alloc] initWithFrame:CGRectMake(0, photoView.bottom-20, pubWidth, 40)];
    [btn_down setBackgroundColor:[UIColor colorWithRed:141.0/255.0 green:141.0/255.0 blue:141.0/255.0 alpha:1.0]];
    [btn_down setImage:[[UIImage imageNamed:@"dislike_rate.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_down setTintColor:[UIColor whiteColor]];
    [btn_down setTitle:@"  Swipe Left for No" forState:UIControlStateNormal];
    [btn_down setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_down.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    [self.view addSubview:btn_down];
    
    lblIntro2 = [[UILabel alloc] initWithFrame:CGRectMake(0, btn_down.bottom, pubWidth, 40)];
    lblIntro2.font = [UIFont boldSystemFontOfSize:17];
    lblIntro2.textColor = COLOR_IN_BLACK;
    lblIntro2.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:lblIntro2];
    
//    flagBtn = [[UIButton alloc] initWithFrame:CGRectMake(photoView.width-42, photoView.height-42, 32, 32)];
//    [flagBtn setImage:[[UIImage imageNamed:@"flagreport.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [flagBtn setTintColor:COLOR_TINT_SECOND];
//    [flagBtn addTarget:self action:@selector(flagBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    
    [self.view addSubview:btn_up];

    UIButton *btn_how = [[UIButton alloc] initWithFrame:CGRectMake(0, lblIntro2.bottom, pubWidth*0.7, self.view.height-lblIntro2.bottom-64-44)];
    [btn_how setBackgroundColor:[UIColor colorWithRed:171.0/255.0 green:108.0/255.0 blue:196.0/255.0 alpha:1.0]];
    [btn_how setImage:[[UIImage imageNamed:@"info_squ.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_how setTintColor:[UIColor whiteColor]];
    [btn_how setTitle:@" How it Works?" forState:UIControlStateNormal];
    [btn_how setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_how setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    btn_how.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn_how addTarget:self action:@selector(btn_how_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn_how];

    UIButton *btn_flag = [[UIButton alloc] initWithFrame:CGRectMake(pubWidth*0.7, lblIntro2.bottom, pubWidth*0.3, self.view.height-lblIntro2.bottom-64-44)];
    [btn_flag setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:139.0/255.0 blue:135.0/255.0 alpha:1.0]];
    [btn_flag setImage:[[UIImage imageNamed:@"info_tri.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_flag setTintColor:[UIColor whiteColor]];
    [btn_flag setTitle:@" Flag" forState:UIControlStateNormal];
    [btn_flag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_flag setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    btn_flag.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn_flag addTarget:self action:@selector(btn_flag_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn_flag];

    
    UISwipeGestureRecognizer *swipe_ges_up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipe_ges_up.direction = UISwipeGestureRecognizerDirectionUp;

    
    UISwipeGestureRecognizer *swipe_ges_down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipe_ges_down.direction = UISwipeGestureRecognizerDirectionDown;

    photoArray = [NSArray array];
    
    NSMutableArray *array_checked = [NSMutableArray array];
    
    if([PFUser currentUser][PF_USER_LIKES]) {
        [array_checked addObjectsFromArray:[PFUser currentUser][PF_USER_LIKES]];
    }
    if([PFUser currentUser][PF_USER_DISLIKES]) {
        [array_checked addObjectsFromArray:[PFUser currentUser][PF_USER_DISLIKES]];
    }
    
    PFQuery *query_me = [PFQuery queryWithClassName:PF_CONTEST_CLASS];
    [query_me whereKey:PF_CONTEST_USER equalTo:[PFUser currentUser]];
    
    [query_me countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(!error) {
            
            if(number == 0) {
                lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
            } else {
                lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*number-(int)array_checked.count];
            }
            myTestPhoto_Number = number;
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_CONTEST_CLASS];
    [query whereKey:@"createdAt" greaterThan:[NSDate dateYesterday]];
    [query whereKey:@"objectId" notContainedIn:array_checked];
    
    query.limit = 60;
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[KIProgressViewManager manager] hideProgressView];

        if(!error) {
            cardsLoadedIndex = 0;
            photoArray = objects;
            NSLog(@"object Count ==%lu",(unsigned long)objects.count);
//            [self loadPhotos];
            [self loadCards];

        }
    }];
        
    // Do any additional setup after loading the view.
}
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    PFObject *object = [photoArray objectAtIndex:index];
    NSString *photo_url = object[PF_CONTEST_THUMB];

    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(0, lblIntro.bottom+40, CARD_WIDTH, CARD_HEIGHT-40)];
    [draggableView.backView setImageWithURL:[NSURL URLWithString:photo_url] placeholderImage:[UIImage imageNamed:@"placeholder_gb.png"]];
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([photoArray count] > 0) {
        NSInteger numLoadedCardsCap =(([photoArray count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[photoArray count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[photoArray count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        
        NSLog(@"PhotoArray == %lu",(unsigned long)[photoArray count]);
        NSLog(@"LoadCard == %lu",(unsigned long)[loadedCards count]);
        
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self.view insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self.view addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{

    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self.view insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        
        int myTestedCount = (int)[[PFUser currentUser][PF_USER_LIKES] count]+(int)[[PFUser currentUser][PF_USER_DISLIKES] count];
        NSLog(@"testCount == %d",myTestPhoto_Number);
        if(myTestPhoto_Number == 0) {
            lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
        } else {
            lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*myTestPhoto_Number-myTestedCount];
        }


    } else {
        int myTestedCount = (int)[[PFUser currentUser][PF_USER_LIKES] count]+(int)[[PFUser currentUser][PF_USER_DISLIKES] count];
        
        if(myTestPhoto_Number == 0) {
            lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
        } else {
            lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*myTestPhoto_Number-myTestedCount];
        }
    }
    [self btnDislikeClicked];
}


-(void)cardSwipedRight:(UIView *)card
{
   
    [loadedCards removeObjectAtIndex:0];
    
    if (cardsLoadedIndex < [allCards count])
    {
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;
        [self.view insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:
         
         [loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        
        int myTestedCount = (int)[[PFUser currentUser][PF_USER_LIKES] count]+(int)[[PFUser currentUser][PF_USER_DISLIKES] count];
        
        
        
        if(myTestPhoto_Number == 0) {
            lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
        } else {
            lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*myTestPhoto_Number-myTestedCount];
        }

    } else {
        
        int myTestedCount = (int)[[PFUser currentUser][PF_USER_LIKES] count]+(int)[[PFUser currentUser][PF_USER_DISLIKES] count];
        
        if(myTestPhoto_Number == 0) {
            lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
        } else {
            lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*myTestPhoto_Number-myTestedCount];
        }

    }
    
    [self btnLikeClicked];
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        [self flagBtnClicked];
    }
    
}

- (void)btn_how_clicked:(id) sender {
    
    if(lblIntroduction.hidden) {
        lblIntro.hidden = YES;
        lblIntroduction.hidden = NO;
    } else {
        lblIntro.hidden = NO;
        lblIntroduction.hidden = YES;
    }
    
}

- (void)btn_flag_clicked:(id) sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Does the picture contain inappropriate content?" delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes",nil];
    [alertView show];

}

- (void)flagBtnClicked {
    
    PFObject *obj = [photoArray objectAtIndex:cardsLoadedIndex];
    NSMutableArray *array = obj[PF_CONTEST_FLAGGING];
    if(!array)
        array = [NSMutableArray array];
    
    if([obj[PF_CONTEST_FLAGGING] containsObject:[PFUser currentUser].objectId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You already flagged" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    } else {
        [array addObject:[PFUser currentUser].objectId];
        obj[PF_CONTEST_FLAGGING] = array;
        [obj saveInBackground];
    }
    
    
}
- (void)loadPhotos {
    
    if(cardsLoadedIndex<photoArray.count) {
        PFObject *obj = [photoArray objectAtIndex:cardsLoadedIndex];
        NSString *photo_url = obj[PF_CONTEST_THUMB];
        [photoView setImageWithURL:[NSURL URLWithString:photo_url] placeholderImage:[UIImage imageNamed:@"placeholder_gb.png"]];
        
        int myTestedCount = (int)[[PFUser currentUser][PF_USER_LIKES] count]+(int)[[PFUser currentUser][PF_USER_DISLIKES] count];
        
        if(myTestPhoto_Number == 0) {
            lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
        } else {
            lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*myTestPhoto_Number-myTestedCount];
        }
        
        
    } else {
        photoView.image = nil;
        int myTestedCount = (int)[[PFUser currentUser][PF_USER_LIKES] count]+(int)[[PFUser currentUser][PF_USER_DISLIKES] count];
        
        if(myTestPhoto_Number == 0) {
            lblIntro2.text = [NSString stringWithFormat:@"You can create your own test!"];
        } else {
            lblIntro2.text = [NSString stringWithFormat:@"Rate %d more people to unlock your result",20*myTestPhoto_Number-myTestedCount];
        }

    }
    
}
- (void)btnDislikeClicked {


    NSInteger numLoadedCardsCap =(([photoArray count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[photoArray count]);

    PFObject *obj;

    
    if (cardsLoadedIndex < [allCards count])   //changed by Michal < -> <+ 7-8
    {
        obj = [photoArray objectAtIndex:cardsLoadedIndex-numLoadedCardsCap-1];
    } else {
        obj = [photoArray objectAtIndex:numLoadedCardsCap-1];
    }
    
    
    NSMutableArray *array = [PFUser currentUser][PF_USER_DISLIKES];
    if(!array)
        array = [NSMutableArray array];
    [array addObject:obj.objectId];
    
    NSMutableArray *array_contest = obj[PF_USER_DISLIKES];
    if(!array_contest)
        array_contest = [NSMutableArray array];
    [array_contest addObject:[PFUser currentUser].objectId];
    
    [PFUser currentUser][PF_USER_DISLIKES] = array;
    obj[PF_CONTEST_DISLIKES] = array_contest;
    
    [obj saveInBackground];
    [[PFUser currentUser] saveInBackground];
    
}

- (void)btnLikeClicked {
    
    NSInteger numLoadedCardsCap =(([photoArray count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[photoArray count]);
    PFObject *obj;
    if (cardsLoadedIndex < [allCards count]) //changed by Michal < -> <+ 7-8
    {
        obj = [photoArray objectAtIndex:cardsLoadedIndex-numLoadedCardsCap-1];
    } else {
        obj = [photoArray objectAtIndex:numLoadedCardsCap - 1];
    }
    NSMutableArray *array = [PFUser currentUser][PF_USER_LIKES];
    if(!array)
        array = [NSMutableArray array];
    [array addObject:obj.objectId];
    
    NSMutableArray *array_contest = obj[PF_CONTEST_LIKES];
    if(!array_contest)
        array_contest = [NSMutableArray array];
    [array_contest addObject:[PFUser currentUser].objectId];
    
    [PFUser currentUser][PF_USER_LIKES] = array;
    obj[PF_USER_LIKES] = array_contest;
    
    [obj saveInBackground];
    [[PFUser currentUser] saveInBackground];
    

}

- (void)swipeDown:(UISwipeGestureRecognizer *) swipeGes {
    NSLog(@"DOWN");
    [self btnDislikeClicked];
}
- (void)swipeUp:(UISwipeGestureRecognizer *) swipeGes {
    
    NSLog(@"UP");
    [self btnLikeClicked];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - KASlideShow delegate

- (void) kaSlideShowDidNext:(KASlideShow *)slideShow
{
    NSLog(@"kaSlideShowDidNext, index : %lu",(unsigned long)slideShow.currentIndex);
}

-(void)kaSlideShowDidPrevious:(KASlideShow *)slideShow
{
    NSLog(@"kaSlideShowDidPrevious, index : %lu",(unsigned long)slideShow.currentIndex);
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
