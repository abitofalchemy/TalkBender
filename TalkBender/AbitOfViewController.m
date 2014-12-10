//
//  AbitOfViewController.m
//  WebviewJavascript
//
//  Created by Salvador Aguinaga on 12/15/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//
/*  References:
    http://stackoverflow.com/questions/6420925/load-resources-from-relative-path-using-local-html-in-uiwebview
    http://www.raywenderlich.com/42266/augmented-reality-ios-tutorial-location-based

 */

#import "AbitOfViewController.h"
#define  APP_SCREEN_FRAME  [[UIScreen mainScreen] applicationFrame]

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation;
@end

@interface AbitOfViewController () <UIWebViewDelegate>
@property (strong, nonatomic) NSMutableArray *tblDataSourceArr;
@property (strong, nonatomic) NSMutableArray *topicsArray;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) NSMutableArray *sciArray;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (strong, nonatomic) NSMutableArray *topicRankAr;
@property (strong, nonatomic) UISegmentedControl* segCtrl;
@property (strong, nonatomic) NSDictionary* tweetsDict;
@property (nonatomic) NSInteger sel;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation{
    // from SO:/questions/19387152/how-to-load-data-into-viewcontroller-from-local-json-file
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:fileLocation ofType:@"json"];
    
    NSData* data = [NSData dataWithContentsOfFile:jsonPath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

@end

@implementation AbitOfViewController
@synthesize locationManager=_locationMananger;

#pragma mark - Default VC methods
- (void)resetAllViews{
    
    
    [UIView animateWithDuration:0.6 animations:^{
        [self.webView setFrame:CGRectMake(0, APP_SCREEN_FRAME.size.height*0.250,
                                          APP_SCREEN_FRAME.size.width*0.75,
                                          APP_SCREEN_FRAME.size.height)];
        CGRect tvFrame = CGRectMake(self.webView.frame.size.width,self.mapView.frame.size.height,
                                    APP_SCREEN_FRAME.size.width*0.250,
                                    APP_SCREEN_FRAME.size.height*0.75);
        [self.tableView setFrame:tvFrame];
        
    } completion:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
                        
                        
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self.mapView setFrame:CGRectMake(0,0,
                                      APP_SCREEN_FRAME.size.width,
                                      APP_SCREEN_FRAME.size.height*0.250)];
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    
    // Add controls:
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"Topics",@"Users",@"SCI"]];
    segmentControl.frame = CGRectMake(6, 6, APP_SCREEN_FRAME.size.width*0.33, 30);
    //segmentControl.tintColor = [UIColor whiteColor];
    [segmentControl addTarget:self
                       action:@selector(segmentedControlValueDidChange:)
             forControlEvents:UIControlEventValueChanged];
    [segmentControl setSelectedSegmentIndex:0];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [shadow setShadowOffset:CGSizeMake(0, 1.2)];
    [segmentControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:16.0],
                                             NSForegroundColorAttributeName:[UIColor blueColor],
                                             NSShadowAttributeName:shadow}
                                  forState:UIControlStateNormal];
    [segmentControl setAlpha:0.8];
    
    // UI webview frame
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, APP_SCREEN_FRAME.size.height*0.250,
                                                               APP_SCREEN_FRAME.size.width*0.75,
                                                               APP_SCREEN_FRAME.size.height)];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index"
                                                                        ofType:@"html"
                                                                   inDirectory:@"www"]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];

    self.webView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.webView.layer.borderWidth = 1.0;
    
    
    // Add Logo
    UIImage* logoImg = [UIImage imageNamed:@"tb_logo_x44.png"];
    CGSize logoImgSize = [logoImg size];
    UIImageView* logoView = [[UIImageView alloc] initWithFrame:
                             CGRectMake(0,0,logoImgSize.width,logoImgSize.height)];
    [logoView setImage:logoImg];
    [logoView setCenter:CGPointMake(APP_SCREEN_FRAME.size.width -logoView.center.x *1.5,
                                    logoView.center.y *1.5)];
    /*[logoView.layer setShadowColor:[UIColor whiteColor].CGColor];
    [logoView.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [logoView.layer setShadowOpacity:0.8];
    [logoView.layer setShadowRadius:4];
    [logoView.layer setShadowPath:[[UIBezierPath
                                        bezierPathWithRect:logoView.bounds] CGPath]];*/
    
    // Add TableView
    CGRect tvFrame = CGRectMake(_webView.frame.size.width,self.mapView.frame.size.height,
                                APP_SCREEN_FRAME.size.width*0.250,
                                APP_SCREEN_FRAME.size.height*0.75);
    self.tableView = [[UITableView alloc] initWithFrame:tvFrame style:UITableViewStylePlain];
    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
    // _______
    // Add slider
    NSUInteger margin = 20;
    CGRect sliderFrame = CGRectMake(0, 0, APP_SCREEN_FRAME.size.width - margin * 2, 30);
    UISlider* timeLineSldr = [[UISlider alloc] initWithFrame:sliderFrame];
    [timeLineSldr.layer setShadowColor:[UIColor whiteColor].CGColor];
    [timeLineSldr.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [timeLineSldr.layer setShadowOpacity:0.8];
    [timeLineSldr.layer setShadowRadius:4];
    [timeLineSldr.layer setShadowPath:[[UIBezierPath
                                  bezierPathWithRect:timeLineSldr.bounds] CGPath]];
    UILabel* timLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [timLineLbl setText:@"Timeline"];
    [timLineLbl setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12.0f]];
    
    
    // add to canvas
    [self.view addSubview:self.mapView];
    [self.mapView addSubview:segmentControl];
    [self.mapView addSubview:timeLineSldr];
    [timeLineSldr addSubview:timLineLbl] ;
    [timLineLbl setCenter:CGPointMake(timeLineSldr.center.x*0.25, timeLineSldr.center.y * 0.6)];
    
    
    [self.view addSubview:logoView];
    [self.view addSubview:_webView];
    [self.view addSubview:self.tableView];
    
    // recenter where needed
    [timeLineSldr setCenter:CGPointMake(self.mapView.center.x,self.mapView.frame.size.height* 0.8)];
    

    
}

//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(applicationDidBecomeActiveNotification:)
//     name:UIApplicationDidBecomeActiveNotification
//     object:[UIApplication sharedApplication]];
//}
//
//- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
//    NSLog(@"[ RELOADING WEBVIEW ]");
//    [self viewDidLoad];
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDataToJson];
    self.sel = 0;
    
    /* Add Notification Center observer to be alerted of any change to NSUserDefaults.
    // Managed app configuration changes pushed down from an MDM server appear in NSUSerDefaults.
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self readDefaultsValues];
                                                  }];
    
    // Call readDefaultsValues to make sure default values are read at least once.
    [self readDefaultsValues];
    */
//    self.webView = [[UIWebView alloc] init];
//    //NSURL *targetURL = [NSURL URLWithString:@"http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIWebView_Class/UIWebView_Class.pdf"];
//    //NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
//    //[self.webView loadRequest:request];
//    
//    [_serverURLUILabel setText:[targetURL path]];
//    NSLog(@"%@",[targetURL path]);
//    
//    //
    
    
}
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:YES];
//
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
////#define APP_SCREEN_FRAME [[UIScreen mainScreen] applicationFrame]
//
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{

    if(navigationType == UIWebViewNavigationTypeFormSubmitted)
    {
        NSString *urlAppIdStr = @"srclm://6a74a419-32238f2e-86847138-36308579-e8cf7fdb-6ba4a91f-a2e582f5-30b74fbd";
        //NSString *urlAppIdStr = @"srclm://SerimResearch";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlAppIdStr]];
        
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSLog(@"[ hyper link ]");
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"[ wv did finish load ]");
    
    /*** Read if file is available
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask,
                                                          YES);
    
    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:@"data.json"];
    NSData   *jsonData = [[NSFileManager defaultManager] contentsAtPath:fullPath];
    
    NSLog(@"%@", fullPath);
    ***/
    //[_activityIndicator stopAnimating];
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}
- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.altitude];
}
#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //1
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"%@", [locations lastObject]);
    
    //2
    CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
    NSLog(@"Received location %@ with accuracy %f", lastLocation, accuracy);
    
    //3
    if(accuracy < 100.0) {
        //4
        MKCoordinateSpan span = MKCoordinateSpanMake(0.14, 0.14);
        MKCoordinateRegion region = MKCoordinateRegionMake([lastLocation coordinate], span);
        
        [_mapView setRegion:region animated:YES];
        
        // More code here
        
        [manager stopUpdatingLocation];
    }
}
#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}
- (void)refreshTableSectionTitles:(NSNotification *)notification {
    [self.tableView reloadData];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sel == 0) {
        return  @"Topics";
    } else if (self.sel == 1){
        return  @"Followers";
    } else {
        return  @"SCI Properties";
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
////    UILabel *myLabel = [[UILabel alloc] init];
////    myLabel.frame = CGRectMake(20, 8, 320, 20);
////    myLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:12.0f];
////    myLabel.text = [self.tableView h]
////    
//////    NSLog(@"%ld", (long)self.segCtrl.selectedSegmentIndex );
//////    NSLog(@"in viewForHeaderInSection %ld", (long)section); // I only see this once
//////    NSLog(@"return view for section %ld", section);         // this is 0 when I see it
////    
////    // gather content for header
////    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40.0)];
////    // add content to header (displays correctly)
////    [headerView addSubview:myLabel];
//
//
//    return tableView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}
// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tblDataSourceArr count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *cellIdentifier = @"";
//    //static NSString *cellIdentifier = @"tweetCell";
//    if (self.segCtrl.selectedSegmentIndex == 0) {
//         cellIdentifier = @"tweetCell";
//    } else {
//        //caseAtIndexPath = [self.awaitingReviewCaseList caseAtIndex:indexPath.row];
//        cellIdentifier = @"segmentTwo";
//    }
    /**
    // Similar to UITableViewCell, but
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    **/
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    // Just want to test, so I hardcode the data
    cell.textLabel.text = [self.tblDataSourceArr objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0f];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    return cell;
}
#pragma mark - UISegmentControl action
-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
//
    
    NSURL *url0 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index"
                                                                         ofType:@"html"
                                                                    inDirectory:@"www"]];
    NSURL *url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"users"
                                                                         ofType:@"html"
                                                                    inDirectory:@"www"]];
    switch (segment.selectedSegmentIndex) {
        case 0:
            self.sel = 0;//action for the first button (Current)
            [self.tblDataSourceArr removeAllObjects];
            [self.tblDataSourceArr setArray:self.topicsArray];
            [self.tableView reloadData];
            [_webView loadRequest:[NSURLRequest requestWithURL:url0]];
            break;
        case 1:
            self.sel = 1;//action for the first button (Current)
            [self.tblDataSourceArr removeAllObjects];
            [self.tblDataSourceArr setArray:self.usersArray];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
            [_webView loadRequest:[NSURLRequest requestWithURL:url1]];
            break;
        case 2:
            self.sel = 2;
            [self.tblDataSourceArr removeAllObjects];
            [self.tblDataSourceArr setArray:@[@"SBTribune", @"WSBT22"]];
            [self.tableView reloadData];
            [_webView loadRequest:[NSURLRequest requestWithURL:url0]];
            break;
        default:
            break;
    }
    [self resetAllViews];
}
#pragma mark - Local Actions
//- (void) changeTableView{
//    [self.tableView setFrame:CGRectMake(self.webView.frame.size.width,
//                                        self.tableView.frame.origin.y,
//                                        self.view.frame.size.width - self.webView.frame.size.width,
//                                        self.webView.frame.size.height)];
//
//}
- (void) shrinkCloudAndTable:(UITableView*)theTableView
{
    CGRect wvOrigFrm = self.webView.frame;
    [UIView animateWithDuration:0.6 animations:^{
        [self.webView setFrame:CGRectMake(0,wvOrigFrm.origin.y,
                                          wvOrigFrm.size.width*0.25,wvOrigFrm.size.height)];
        [theTableView setFrame:CGRectMake(wvOrigFrm.size.width*0.25,theTableView.frame.origin.y,
                                          self.view.frame.size.width - wvOrigFrm.size.width*0.25,
                                          theTableView.frame.size.height)];

    }];
//     completion:^(BOOL finished) {
//        [self.webView  stopLoading ];
//        [self.webView  reload];
//    }];
    
    
    
}
-(void) showTweetsFor{
    
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    [self shrinkCloudAndTable:tableView];
//    NSLog(@"selectedSegmentIndex: %ld", self.sel);
    if (self.sel == 0){
        [self showTweetsWithAnimation:0
                        withTopic:[self.tblDataSourceArr objectAtIndex:indexPath.row]];
    } else if (self.sel == 1)
    {
        [self showTweetsWithAnimation:1
                            withTopic:[self.tblDataSourceArr objectAtIndex:indexPath.row]];
    }
    
}
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
    
    */
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"politics"
                                                                        ofType:@"html"
                                                                   inDirectory:@"www"]];
    switch (self.segCtrl.selectedSegmentIndex) {
        case 0:
            NSLog(@"segment: 0, topic selecte: %@", [self.tblDataSourceArr objectAtIndex:indexPath.row]);
            [_webView loadRequest:[NSURLRequest requestWithURL:url]];
            break;
        case 1:
            break;
        default:
            break;
    }
}
-(void) showTweetsWithAnimation:(NSInteger)sel_seg_ctrl_index
                      withTopic:(NSString*)topicStr
{
    if (sel_seg_ctrl_index == 0) {
        self.tweetsDict = [NSDictionary dictionaryWithContentsOfJSONString:@"www/tweets"];
        NSMutableArray* tmp_Array = [[NSMutableArray alloc] init];
        for (NSDictionary* topicDict in [self.tweetsDict objectForKey:@"topics"])
            for (NSDictionary* tweetsDic in [topicDict objectForKey:@"tweets"])
                [tmp_Array addObject:[tweetsDic objectForKey:@"text"]];
            
        [UIView animateWithDuration:0.6
         animations:^{
         [self.tblDataSourceArr removeAllObjects];
         self.tblDataSourceArr  = tmp_Array;
         [self.tableView reloadData];
         }];
        
    }
    else if (sel_seg_ctrl_index == 1) {
        self.tweetsDict = [NSDictionary dictionaryWithContentsOfJSONString:@"www/tweets"];
        NSMutableArray* tmp_Array = [[NSMutableArray alloc] init];
        for (NSDictionary* topicDict in [self.tweetsDict objectForKey:@"topics"])
            for (NSDictionary* tweetsDic in [topicDict objectForKey:@"tweets"])
                [tmp_Array addObject:[tweetsDic objectForKey:@"text"]];
        
        [UIView animateWithDuration:0.6
                         animations:^{
                             [self.tblDataSourceArr removeAllObjects];
                             self.tblDataSourceArr  = tmp_Array;
                             [self.tableView reloadData];
                         }];
    }
}
-(void) recurseJson2getLeaves:(NSDictionary *)dict {
    //NSMutableArray* tempArr = [[NSMutableArray alloc] init];
    for (id key in dict){
        id object = [dict objectForKey:key];
        
                     
        if ([(NSString*)key isEqualToString:@"children"]){
            NSArray* tmpArr = object;
            for (NSDictionary* newdict in tmpArr){
                [self recurseJson2getLeaves:newdict];
            }
        }else if ([(NSString*)key isEqualToString:@"size"]){
            //NSLog(@"%@", dict.allValues);
            [self.topicsArray addObject:[dict objectForKey:@"name"]];
            [self.topicRankAr addObject:[dict objectForKey:@"size"]];
//            NSArray* theArr = @[@"name",@"size"];
//            NSArray* xkeys  = dict.allKeys;
//            NSMutableArray *arrayOneCopy = [NSMutableArray arrayWithArray:theArr];
//            [arrayOneCopy removeObjectsInArray:xkeys];
//            if ([theArr isEqualToArray:xkeys])
//                NSLog(@"%@,%@",[dict objectForKey:@"name"],[dict objectForKey:@"size"]);
            
        }
            
        
        
    }
    //NSLog(@"screen_names  %@", tempArr);

    return;
}
- (NSArray*) getUsersArrayFromDict:(NSDictionary*) jsonDict{
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary* dict in [jsonDict valueForKey:@"children"])
        for (NSDictionary* nDict in [dict valueForKey:@"children"])
            [temp addObject:[nDict valueForKey:@"name"]];
    return temp;
    
}

- (void)  setDataToJson{
    // http://stackoverflow.com/questions/14389131/populate-uitableview-with-nsdictionary-contained-parsed-json-data-from-a-mysql-d
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfJSONString:@"www/flare_min"];
    self.topicsArray = [[NSMutableArray alloc] init];
    [self recurseJson2getLeaves:dict];
    // default dataSource
    self.tblDataSourceArr = [[NSMutableArray alloc] initWithArray:self.topicsArray];
    
    
    self.topicRankAr = [[NSMutableArray alloc] init];
    
    self.sciArray    = [[NSMutableArray alloc] initWithArray:@[@"SBTribune", @"WSBT22"]];
    
    // getting the users
    dict = [NSDictionary dictionaryWithContentsOfJSONString:@"www/toy_users"];
    self.usersArray  = [[NSMutableArray alloc] initWithArray:[self getUsersArrayFromDict:dict]];
    
    // getting the tweets
    //self.tweetsDict = [NSDictionary dictionaryWithContentsOfJSONString:@"www/tweets"];
    
    
}

@end
