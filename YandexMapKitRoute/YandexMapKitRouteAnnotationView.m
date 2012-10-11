//
//  YandexMapKitRoutaAnnotationView.m
//  YandexMapKitRoute
//
//  Created by Eugen Antropov on 10/10/12.
//  Copyright (c) 2012 Eugen Antropov. All rights reserved.
//

#import "YandexMapKitRouteAnnotationView.h"

@implementation YandexMapKitRouteAnnotationView
@synthesize routeArray,mapView;
- (id)init{
    self=[super init];
    if(self){
        
    }
    return self;
}

- (void) updateImage{
    float minX=MAXFLOAT;
    float minY=MAXFLOAT;
    float maxX=0;
    float maxY=0;
    float zoomScale = [mapView zoomScale];
    
    float constantY=2900*1.78*(21.535057/(mapView.metersInPixel / zoomScale));
    float constantX=2900*(21.535057/(mapView.metersInPixel / zoomScale));
    for (NSDictionary * position in routeArray) {
        if([[position objectForKey:@"X"] floatValue]>maxX)
            maxX=[[position objectForKey:@"X"] floatValue];
        if([[position objectForKey:@"Y"] floatValue]>maxY)
            maxY=[[position objectForKey:@"Y"] floatValue];
        if([[position objectForKey:@"X"] floatValue]<minX)
            minX=[[position objectForKey:@"X"] floatValue];
        if([[position objectForKey:@"Y"] floatValue]<minY)
            minY=[[position objectForKey:@"Y"] floatValue];
    }
    maxX=maxX-minX;
    maxY=maxY-minY;
    maxX*=constantX;
    maxY*=constantY;
    UIGraphicsBeginImageContext(CGSizeMake(maxX, maxY));
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    CGContextTranslateCTM(
                          context, 0,
                          maxY);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetLineWidth(context, 5.0);
     CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor);
    
    CGContextMoveToPoint(context, ([[[routeArray objectAtIndex:0] objectForKey:@"X"] floatValue]-minX)*constantX , ([[[routeArray objectAtIndex:0] objectForKey:@"Y"] floatValue]-minY)*constantY);
    for (NSDictionary * position in routeArray) {
        CGContextAddLineToPoint(context, ([[position objectForKey:@"X"] floatValue]-minX)*constantX,([[position objectForKey:@"Y"] floatValue]-minY)*constantY);
    }
    
    CGContextStrokePath(context);
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


@end