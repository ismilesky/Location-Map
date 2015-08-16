//
//  KFAnnotationView.m
//  系统地图导航
//
//  Created by lanou3g on 15/8/15.
//  Copyright (c) 2015年 KF. All rights reserved.
//

#import "KFAnnotationView.h"
#import "KFAnnotion.h"
@implementation KFAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView
{
    static NSString *indentifier = @"annotation";
    KFAnnotationView *annotationView = (KFAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:indentifier];
    // 从缓冲池中取出
    if (!annotationView) {
        annotationView = [[KFAnnotationView alloc]initWithAnnotation:nil reuseIdentifier:indentifier];
        // 可以点击交互
        annotationView.canShowCallout = YES;
        
        
        // 设置辅助视图
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return annotationView;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    KFAnnotion *KFannotation = annotation;
    self.image = [UIImage imageNamed:KFannotation.icon];
    
}


@end
