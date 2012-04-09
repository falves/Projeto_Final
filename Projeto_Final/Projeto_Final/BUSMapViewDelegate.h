//
//  BUSMapViewDelegate.h
//  os4Maps
//
//  Created by Felipe Alves on 09/04/12.
//  Copyright (c) 2012 Bitix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AnnotationPonto.h"

@interface BUSMapViewDelegate : NSObject <MKMapViewDelegate>
{
}

@property (nonatomic, strong) MKPolyline *routeLine;
@property (nonatomic, strong) MKPolylineView *routeLineView;
@property (nonatomic, assign) MKMapRect routeRect;
@property (nonatomic, assign) MKMapView * mapView;

- (void) exibeRotaDe:(CLLocationCoordinate2D) pontoOrigem ate:(CLLocationCoordinate2D) pontoDestino comWaypoints:(NSArray*) waypoints;


@end
