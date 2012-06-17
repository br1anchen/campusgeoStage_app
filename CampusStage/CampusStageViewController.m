//
//  CampusStageViewController.m
//  CampusStage
//
//  Created by Brian Chen on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CampusStageViewController.h"
#import "ASIHTTPRequest.h"
#import "GeoInfo.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface CampusStageViewController ()

@end

@implementation CampusStageViewController
@synthesize connectionPeers,connectionPicker,connectionSession;
@synthesize mapView,areaText;
@synthesize annotationPoint,username;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    connectionPicker = [[GKPeerPickerController alloc] init];
    connectionPicker.delegate = self;
    connectionPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    connectionPeers = [[NSMutableArray alloc]init];
    
    username = @"";
    self.mapView.delegate = self;
    
    [self populateMapWithLocation];
    [connectionPicker show];
	// Do any additional setup after loading the view, typically from a nib.
    
    [NSTimer scheduledTimerWithTimeInterval:5 target: self selector:@selector(refreshMap) userInfo:nil repeats:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)populateMapWithLocation
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/geo/all?key=08124146",[self getHostAddress]]];//set the url of server
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url]; //make a ASIHTTP request 
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"GET"];
    [request startSynchronous]; //start to send the message
    
    NSError *error;
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:&error];
    if(json != nil){
        for(NSDictionary *geoData in json){
            GeoInfo *geoinfo = [[GeoInfo alloc]init];
            [geoinfo setTitle:[NSString stringWithFormat:@"%@(%@)",[geoData objectForKey:@"bindUser"],[geoData objectForKey:@"area"]]];
            [geoinfo setSubtitle:[NSString stringWithFormat:@"%@ %@",[geoData objectForKey:@"date"],[geoData objectForKey:@"time"]]];
            [geoinfo setLatitude:[geoData objectForKey:@"latitude"]];
            [geoinfo setLongitude:[geoData objectForKey:@"longitude"]];
            
            CLLocationCoordinate2D annotationCoord;
            
            annotationCoord.latitude = [geoinfo.latitude doubleValue];
            annotationCoord.longitude = [geoinfo.longitude doubleValue];
            
            self.annotationPoint = [[MKPointAnnotation alloc] init];
            self.annotationPoint.coordinate = annotationCoord;
            self.annotationPoint.title = geoinfo.title;
            self.annotationPoint.subtitle = geoinfo.subtitle;
            
            [self.mapView addAnnotation:self.annotationPoint];
            [self.mapView selectAnnotation:self.annotationPoint animated:YES];
        }
    }
    
   
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.annotationPoint.coordinate, 50,50) animated:YES];
}

- (IBAction)sendIndoorInfo:(id)sender {
    [connectionSession disconnectFromAllPeers];
    [connectionPeers removeAllObjects];
    NSLog(@"username:%@",username);
    if([username length] > 0)
    {
        //set location to test
        NSString *latitude = @"31.274697";
        NSString *longitude = @"121.459672";
        int geoType = 4;
        NSLog(@"%@",self.areaText.text);
        NSString *apiAddress = [NSString stringWithFormat:@"http://%@/geo/update?username=%@&latitude=%@&longitude=%@&geoType=%d&area=%@",[self getHostAddress],username,latitude,longitude,geoType,self.areaText.text];
        NSLog(@"%@",apiAddress);
        NSURL *url = [NSURL URLWithString:apiAddress];//set the url of server
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url]; //make a ASIHTTP request 
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"GET"];
        [request startSynchronous]; //start to send the message
        NSString *strResponse = [request responseString];
        if([strResponse isEqualToString:@"\"create\""]){
            NSLog(@"create location success");
            NSLog(@"user:%@",username);
            NSLog(@"latitude:%@",latitude);
            NSLog(@"longitude:%@",longitude);
            NSLog(@"area:%@",areaText);
        }else if( [strResponse isEqualToString:@"\"update\""]){
            NSLog(@"update location success");
            NSLog(@"user:%@",username);
            NSLog(@"latitude:%@",latitude);
            NSLog(@"longitude:%@",longitude);
            NSLog(@"area:%@",areaText);
        }else
        {
            NSLog(@"push location failed");
        }

    }
}

-(NSString *)getHostAddress
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    return [userPrefs stringForKey:@"hostaddress"];
}

-(void)refreshMap
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self populateMapWithLocation];
}

#pragma mark - GKPeerPickerControllerDelegate
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    // Create a session with a unique session ID - displayName:nil = Takes the iPhone Name
    GKSession* session = [[GKSession alloc] initWithSessionID:@"edu.campusgeo.connect" displayName:nil sessionMode:GKSessionModePeer];
    return session;
}

// Tells us that the peer was connected
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    // Get the session and assign it locally
    self.connectionSession = session;
    session.delegate = self;
    
    [picker dismiss];
}

#pragma mark - GKSessionDelegate

// Function to receive data when sent from peer
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    username = str;
    NSLog(@"receive:%@",username);
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    if (state == GKPeerStateConnected) {
        // Add the peer to the Array
        [connectionPeers addObject:peerID];
        
        // Used to acknowledge that we will be sending data
        [session setDataReceiveHandler:self withContext:nil];
        
        //In case you need to do something else when a peer connects, do it here
    }
    else if (state == GKPeerStateDisconnected) {
        [self.connectionPeers removeObject:peerID];
        //Any processing when a peer disconnects
    }
}
@end
