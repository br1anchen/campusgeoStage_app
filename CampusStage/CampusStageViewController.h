//
//  CampusStageViewController.h
//  CampusStage
//
//  Created by Brian Chen on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <MapKit/MapKit.h>

@interface CampusStageViewController : UIViewController<MKMapViewDelegate,GKSessionDelegate,GKPeerPickerControllerDelegate>
{
    GKSession *connectionSession;
    GKPeerPickerController *connectionPicker;
    NSMutableArray *connectionPeers;
}

@property (retain) GKSession *connectionSession;
@property (nonatomic,retain) NSMutableArray *connectionPeers;
@property (nonatomic,retain) GKPeerPickerController *connectionPicker;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UITextField *areaText;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) MKPointAnnotation *annotationPoint;

- (IBAction)sendIndoorInfo:(id)sender;
- (IBAction)connectPeer:(id)sender;

@end
