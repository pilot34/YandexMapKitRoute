//
//  YandexMapKitRoute.h
//  YandexMapKitRoute
//
//  Created by Eugen Antropov on 10/8/12.
//  Copyright (c) 2012 Eugen Antropov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YandexMapKit.h"

@class YandexMapKitRoute;
typedef void(^YandexMapKitRouteBlock)(YandexMapKitRoute *route);

@class YandexMapKitRouteDelegate;

@interface YMKMapViewInternal : UIView
- (CGPoint) mapOverlayView: (UIView *) obj viewPointForXY:(CGPoint) point;
- (id) mapOverlayView:(id) obj calloutViewForAnnotation:(id) obj2;
- (CGRect) mapOverlayView:(id) obj boundaryRectForAnnotationView:(id) obj2 ;
- (void) mapOverlayView:(id) obj setShouldDisableScrolling:(BOOL) obj2;
- (BOOL) mapOverlayView:(id) obj shouldScrollAnnotationViewToVisible:(id) obj2;
@end

@interface YandexMapKitRoute : UIView{

}
@property (nonatomic) YMKMapView * YMKMapViewInternal;
@property (nonatomic) UIScrollView<UIScrollViewDelegate> * YXScrollView;
@property (nonatomic) YandexMapKitRouteDelegate * delegate;
@property (nonatomic) NSArray * geoPointArray;

+ (void)showRouteOnMap:(YMKMapView *)mapView
                  from:(YMKMapCoordinate)coordinateFrom
                    to:(YMKMapCoordinate)coordinateTo
                action:(YandexMapKitRouteBlock)action;
@end
