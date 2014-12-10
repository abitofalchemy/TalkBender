//
//  AbitOfViewController.h
//  WebviewJavascript
//
//  Created by Salvador Aguinaga on 12/15/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AbitOfViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    CLLocation * currentLocation;
    CLLocationManager * locationManager;
}
@property (strong, nonatomic) IBOutlet UIWebView*   webView;
@property (strong, nonatomic) IBOutlet UITableView*   tableView;
//@property (strong, nonatomic) IBOutlet UITableView*   tweetsTblView;
@property (nonatomic,retain) CLLocationManager*     locationManager;
@property (nonatomic,strong) MKMapView*             mapView;
@property (nonatomic,strong) CLLocation             *location;
@property (nonatomic,assign) CLLocationDistance     radius;


@end
