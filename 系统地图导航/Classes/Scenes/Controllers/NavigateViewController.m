//
//  NavigateViewController.m
//  系统地图导航
//
//  Created by lanou3g on 15/8/15.
//  Copyright (c) 2015年 KF. All rights reserved.
//

#import "NavigateViewController.h"
#import "KFAnnotion.h"
#import <MapKit/MapKit.h>

@interface NavigateViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *distinationLable;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation NavigateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // iOS请求授权 (方式2)
    if ([CLLocationManager locationServicesEnabled]) {
        // 判断当前版本是否为iOS8
        if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    // 设置开始定位
    [self.locationManager startUpdatingLocation];
    
    // 设置用户跟随模式
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    // 设置代理
    self.mapView.delegate = self;

}

#pragma mark - 懒加载
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

#pragma mark - 当前用户位置
/**
 *  获取用户的当前位置
 *
 *  @param mapView
 *  @param userLocation 用户的位置信息,显示系统大头针
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@",userLocation);
}


#pragma mark - 导航(进入系统的地图)
- (IBAction)navigate:(UIButton *)sender {
     [self.view endEditing:YES];
    if (self.distinationLable.text.length == 0) return;
    
    // 进行地理编码,获得将到达的位置
    [self.geocoder geocodeAddressString:self.distinationLable.text completionHandler:^(NSArray *placemarks, NSError *error) {
    if (placemarks.count == 0 || error) {
        
        // 获取CLPlacemark(地标)
        CLPlacemark *mark = [placemarks firstObject];
        // 根据CLPlacemark对象获得MKPlacemark对象
        MKPlacemark *MKmark = [[MKPlacemark alloc]initWithPlacemark:mark];
        // 获取起始位置
        MKMapItem *sourceItem = [MKMapItem mapItemForCurrentLocation];
        // 创建达到的MKMapItem
        MKMapItem *distinationItem = [[MKMapItem alloc]initWithPlacemark:MKmark];
        // 开始导航
        [self startNavigateFromSourceItem:sourceItem toDistinationItem:distinationItem];
        
//        NSArray *mapItems = @[sourceItem,distinationItem];
//        
//        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey:@YES};
//        
//        // 进入系统的导航界面
//        [MKMapItem openMapsWithItems:mapItems launchOptions:options];

        
    }

    }];
}

/**
 *  导航设置
 *
 *  @param sourceItem      起始地
 *  @param distinationItem 目的地
 */
- (void)startNavigateFromSourceItem:(MKMapItem *)sourceItem toDistinationItem:(MKMapItem *)distinationItem
{
    NSArray *mapItems = @[sourceItem,distinationItem];
    
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey:@YES};
    
    // 进入系统的导航界面
    [MKMapItem openMapsWithItems:mapItems launchOptions:options];
}




#pragma mark - 画出当前位置和目的地路线图
- (IBAction)drawRoute:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    // 获取当前位置
    MKMapItem *sourceItem = [MKMapItem mapItemForCurrentLocation];
    // 进行地理编码,获得将到达的位置
    [self.geocoder geocodeAddressString:self.distinationLable.text completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *CLmark = [placemarks lastObject];
        // 通过 CLPlacemark创建 MKPlacemark
        MKPlacemark *MKmark = [[MKPlacemark alloc]initWithPlacemark:CLmark];
        
        // 添加大头针
        KFAnnotion *annotation = [[KFAnnotion alloc]init];
        annotation.coordinate = MKmark.location.coordinate;
        annotation.title = MKmark.locality ? MKmark.administrativeArea : MKmark.locality;
        annotation.subtitle = MKmark.name;
        [self.mapView addAnnotation:annotation];
        
        // 创建目的地的位置
        MKMapItem *distinationItem = [[MKMapItem alloc]initWithPlacemark:MKmark];
        
        // 画出路线
        [self drawRouteFromSourceItem:sourceItem toDistinationItem:distinationItem];
    }];
    
}

/**
 *  画出目的地和当前位置的路线图
 *
 *  @param sourceItem      起始地
 *  @param distinationItem 目的地
 */
- (void)drawRouteFromSourceItem:(MKMapItem *)sourceItem toDistinationItem:(MKMapItem *)distinationItem
{
    // 创建请求
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    
    // 设置起始点和终点的MKMapItem
    request.source = sourceItem;
    request.destination = distinationItem;
    
    // 创建MKDirections
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    // 使用MKDirections请求数据(可以请求导航的线路)
     [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
         // 遍历所有的路线
         for (MKRoute *route in response.routes) {
             NSLog(@"%f---%f",route.distance,route.expectedTravelTime/3600);
             
             // 添加遮盖
             [self.mapView addOverlay:route.polyline];
         }
     }];
}

/**
 *  添加遮盖调用
 *
 *  @param mapView
 *  @param overlay 路线
 *
 *  @return 路线
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    // 创建遮盖的渲染对象
    MKPolylineRenderer *ployRenderer = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
    // 设置线段的宽
    ployRenderer.lineWidth = 5;
    // 设置线段的边框颜色
    ployRenderer.strokeColor = [UIColor redColor];
    // 设置填充色
    ployRenderer.fillColor = [UIColor purpleColor];
    
    return ployRenderer;
}

@end
