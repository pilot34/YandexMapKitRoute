//
//  YandexMapKitRoute.m
//  YandexMapKitRoute
//
//  Created by Eugen Antropov on 10/8/12.
//  Copyright (c) 2012 Eugen Antropov. All rights reserved.
//

#import "YandexMapKitRoute.h"
#import "YandexBase64.h"
#import <objc/runtime.h>
#import "YandexMapKitRouteDelegate.h"


@implementation YandexMapKitRoute
@synthesize YMKMapViewInternal,YXScrollView,delegate;

+ (NSString *) getRouteStringFrom:(YMKMapCoordinate)from To:(YMKMapCoordinate)to{
   NSString * returnString;
    //Address to request route
   NSURL * yandexUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.yandex.ru/services/router/search/1.x/search.json?lang=ru-RU&origin=maps&simplify=1&rll=%f,%f~%f,%f&rtm=atm",from.longitude,from.latitude,to.longitude,to.latitude]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:yandexUrl];
    NSURLResponse* response;
    NSError* error = nil;
    
    //Capturing server response
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    if(result!=nil){
        //NSJSONSerialization reolization
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        returnString=json[@"features"][0][@"features"][1][@"properties"][@"polylod"][@"polyline"];
        //\NSJSONSerialization reolization
        
        //USE this for ios < 5 support
            //SBJson reolization
            //NSDictionary * returnDict=[[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] JSONValue];
            //returnString=[[[returnDict valueForKey:@"stages"] valueForKey:@"encodedPoints"] objectAtIndex:0];
            //\SBJson reolization
    }
    return returnString;
}

+ (void)showRouteOnMap:(YMKMapView *)mapView
                  from:(YMKMapCoordinate)coordinateFrom
                    to:(YMKMapCoordinate)coordinateTo
                action:(YandexMapKitRouteBlock)action
{
    YandexMapKitRoute* returnRoute;
    
    for (UIView * view in ((UIScrollView<UIScrollViewDelegate> *) [mapView.subviews objectAtIndex:1]).subviews) {
        if([view isKindOfClass:[YandexMapKitRoute class]]){
            returnRoute=(YandexMapKitRoute *)view;
        }
    }

    if(returnRoute==nil){
        //Create new View
        returnRoute = [[YandexMapKitRoute alloc] initWithFrame:(CGRect){0,0,mapView.frame.size}];
        //Get UIScrollView
        returnRoute.YXScrollView = (UIScrollView<UIScrollViewDelegate> *) [mapView.subviews objectAtIndex:1];
        //Insert RouteView
        [returnRoute.YXScrollView addSubview:returnRoute];
        returnRoute.YMKMapViewInternal = mapView;

        //Set proxy delegate to handle events
        YandexMapKitRouteDelegate * delegate=[[YandexMapKitRouteDelegate alloc] init];
        if(mapView.delegate!=nil)
            delegate.oldDelegate=mapView.delegate;
        delegate.mapView=mapView;
        mapView.delegate=nil;
        mapView.delegate=delegate;

        //Setting properties of Route view
        [returnRoute setBackgroundColor:[UIColor clearColor]];
        [returnRoute setUserInteractionEnabled:NO];

        delegate.route=returnRoute;
        returnRoute.delegate= delegate;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString * routeString=[YandexMapKitRoute getRouteStringFrom:coordinateFrom To:coordinateTo];
            if(routeString==nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    action(nil);
                    return;
                });
            }
            
            returnRoute.geoPointArray = [YandexMapKitRoute parseData:[YandexBase64 decode:routeString]];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect frame=returnRoute.frame;
                frame.origin=returnRoute.YXScrollView.contentOffset;
                returnRoute.frame=frame;
                [returnRoute setNeedsDisplay];
                action(returnRoute);
            });
        }
        @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                action(nil);
            });
        }
    });
}

- (void) drawRect:(CGRect)rect{

    int z = [self.YMKMapViewInternal zoomLevel];
    //Setting CGContext
    CGContextRef context = UIGraphicsGetCurrentContext();

    //Width of route line
    CGContextSetLineWidth(context, z/2);

    //Color of route line
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor);

    //Move to first position of route
    CGPoint startPoint=[self.YMKMapViewInternal convertLLToMapView:YMKMapCoordinateMake([[[_geoPointArray objectAtIndex:0] objectForKey:@"Y"] floatValue],[[[_geoPointArray objectAtIndex:0] objectForKey:@"X"] floatValue])];
    CGContextMoveToPoint(context, startPoint.x,startPoint.y);

    for (NSDictionary * position in _geoPointArray) {
        CGPoint point=[self.YMKMapViewInternal convertLLToMapView:YMKMapCoordinateMake([[position objectForKey:@"Y"] floatValue],[[position objectForKey:@"X"] floatValue])];
        //Draw route
        CGContextAddLineToPoint(context, point.x,point.y);
    }

    CGContextStrokePath(context);

}

//Function to convert Yandex dif coordinate to absoulute lat long coordinate
+ (NSArray *) parseData:(NSData *) globalData{
    int lastx=0;
    int lasty=0;
    NSMutableArray * mutablePoints=[[NSMutableArray alloc] init];
    for(int i=0; i<[globalData length]/8;i++){
        NSData *data = [globalData subdataWithRange:NSMakeRange((i*8), 4)];
        int value = *(int*)([data bytes]);
        NSData *data2 = [globalData subdataWithRange:NSMakeRange(i*8+4,4)];
        int value2 = *(int*)([data2 bytes]);
        [mutablePoints addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:(value+lastx)/1000000.0f],@"X",[NSNumber numberWithFloat:(value2+lasty)/1000000.0f],@"Y", nil]];
        lastx+=value;
        lasty+=value2;
    }
    return mutablePoints;
}

@end
