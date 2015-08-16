//
//  LocationViewController.m
//  系统地图导航
//
//  Created by lanou3g on 15/8/15.
//  Copyright (c) 2015年 KF. All rights reserved.
//

#import "LocationViewController.h"
#import <MapKit/MapKit.h>
#import "KFAnnotationView.h"
#import "KFAnnotion.h"

@interface LocationViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //  iOS8请求授权(方式1)
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    // 设置开始定位
    [self.locationManager startUpdatingLocation];
    
    // 设置用户跟随模式
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    // 设置代理
    self.mapView.delegate = self;
}


#pragma mark - 地图控件方法
/**
 *  获取用户的位置,更新用户位置，只要用户改变则调用此方法（包括第一次定位到用户位置）
 *
 *  @param mapView
 *  @param userLocation 大头针模型
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 获取当前用户的经纬度
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    NSLog(@"latitude = %f, longitude = %f",coordinate.latitude,coordinate.longitude);
    
    // 设置显示用户的位置,设置地图显示范围(如果不进行区域设置会自动显示区域范围并指定当前用户位置为地图中心点)
//    CLLocationCoordinate2D center = userLocation.location.coordinate;
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.052996, 0.039880);
//    MKCoordinateRegion regin = MKCoordinateRegionMake(center, span);
//    [mapView setRegion:regin animated:YES];
}


/**
 *  滑动地图,区域发生改变时执行
 *
 *  @param mapView  地图
 *  @param animated
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // 打印滑动地域的位置
    NSLog(@"latitude = %f longitude = %f ,latitudeDetal = %f longitude = %f",mapView.region.center.latitude,mapView.region.center.longitude,mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
}

#pragma mark - 懒加载
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
}


#pragma mark - 显示大头针时调用
/**
 *  显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
 *
 *  @param mapView    地图视图
 *  @param annotation 即将显示的大头针对象
 *
 *  @return 显示的大头针对象
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 如果是系统的大头针,返回nil
    if ([annotation isKindOfClass:[MKUserLocation class]])  return nil;
    // 创建自定义的AnnotationView
    KFAnnotationView *annotationView = [KFAnnotationView annotationViewWithMapView:mapView];
    // 传递数据模型
    annotationView.annotation = annotation;
    return annotationView;
}


#pragma mark - 添加大头针
- (IBAction)addAnnotion:(UIButton *)sender {
    KFAnnotion *annotion1 = [[KFAnnotion alloc]init];
    annotion1.title  = @"幸福时光KTV";
    annotion1.subtitle = @"北京市海淀区清河";
    annotion1.coordinate = CLLocationCoordinate2DMake(39.68, 116.16);
    annotion1.icon = @"category_2";
    [self.mapView addAnnotation:annotion1];
    
    KFAnnotion *annotion2 = [[KFAnnotion alloc]init];
    annotion2.title  = @"如家酒店";
    annotion2.subtitle = @"北京市海淀区清河";
    annotion2.coordinate = CLLocationCoordinate2DMake(39.69, 116.19);
    annotion2.icon = @"category_3";
    [self.mapView addAnnotation:annotion2];
}

#pragma mark - 下落动画
/**
 *  自定义下落动画
 *
 *  @param mapView
 *  @param views   所有的MKAnnotationView
 */
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKPinAnnotationView *annotationView in views) {
        // 判断是否是当前的大头针(蓝色定位点)
        if (![annotationView isKindOfClass:[MKPinAnnotationView class]]) {
            CGRect endFrame = annotationView.frame;
            annotationView.frame = CGRectMake(endFrame.origin.x, 0, endFrame.size.width, endFrame.size.height);
            [UIView animateWithDuration:0.5 animations:^{
                annotationView.frame = endFrame;
            }];
        }
    }
}


#pragma mark - 点击回到当前位置
- (IBAction)LocateAction:(UIButton *)sender {
    // 获得经纬度
    CLLocationCoordinate2D coordinate = self.mapView.userLocation.location.coordinate;
    // 获取区域跨度
     MKCoordinateSpan span = MKCoordinateSpanMake(0.052996, 0.039880);
    // 返回当前区域
    MKCoordinateRegion regin = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:regin animated:YES];

}



@end
