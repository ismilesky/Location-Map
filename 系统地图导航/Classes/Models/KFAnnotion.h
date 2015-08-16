//
//  KFAnnotion.h
//  系统地图导航
//
//  Created by lanou3g on 15/8/15.
//  Copyright (c) 2015年 KF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface KFAnnotion : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (copy, nonatomic) NSString *icon;


@end
