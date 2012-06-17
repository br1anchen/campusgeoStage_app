//
//  GeoInfo.h
//  CampusGeo
//
//  Created by Brian Chen on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoInfo : NSObject
{
    NSString *latitude;
    NSString *longitude;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subtitle;

@end
