//
//  BUSMapViewDelegate.m
//  os4Maps
//
//  Created by Felipe Alves on 09/04/12.
//  Copyright (c) 2012 Bitix. All rights reserved.
//

#import "BUSMapViewDelegate.h"

@interface BUSMapViewDelegate()

- (NSArray*) buscarListaDePontosDaRotaComOrigem:(CLLocationCoordinate2D) pontoOrigem eDestino:(CLLocationCoordinate2D) pontoDestino comWaypoints:(NSArray*)waypoints;

@end

@implementation BUSMapViewDelegate

@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize routeRect = _routeRect;
@synthesize mapView = _mapView;

#pragma Mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now. 
		if(nil == self.routeLineView)
		{
			self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
			self.routeLineView.fillColor = [UIColor colorWithRed:60./255. green:140./255. blue:255./255. alpha:0.7];
			self.routeLineView.strokeColor = [UIColor colorWithRed:60./255. green:140./255. blue:255./255. alpha:0.7];
			self.routeLineView.lineWidth = 8;
		}
		
		overlayView = self.routeLineView;
		
	}
	
	return overlayView;
	
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    
    static NSString *identificador = @"OnibusAnnotationIdentifier";
    
    if([annotation isKindOfClass:[AnnotationPonto class]]){
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identificador];
        if (pinView ==nil) {
            
            pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identificador];
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.animatesDrop = YES;
            
        } 
        return pinView;
    }
    
    
    
    return nil;
}

#pragma Mark - Metodos Auxiliares

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
    
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
    
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //		printf("[%f,", [latitude doubleValue]);
        //		printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

- (NSArray*) buscarListaDePontosDaRotaComOrigem:(CLLocationCoordinate2D) pontoOrigem eDestino:(CLLocationCoordinate2D) pontoDestino comWaypoints:(NSArray*)waypoints {
    
    //http://maps.googleapis.com/maps/api/directions/json?origin=-22.960414,-43.205895&destination=-22.960994,-43.206705&waypoints=-22.962130,-43.207257&dirflg=r&sensor=false
    
    NSString * stringOrigem = [NSString stringWithFormat:@"%f,%f", pontoOrigem.latitude, pontoOrigem.longitude];
    NSString * stringDestino = [NSString stringWithFormat:@"%f,%f", pontoDestino.latitude, pontoDestino.longitude];
    NSString * stringWaypoints = @"";
    
    for (NSDictionary * waypoint in waypoints) {
        
        stringWaypoints = [stringWaypoints stringByAppendingFormat:@"%@,%@|",[waypoint objectForKey:@"latitude"],[waypoint objectForKey:@"longitude"]];
    }
    
    NSString * urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&waypoints=%@&dirflg=r&sensor=true",stringOrigem,stringDestino,stringWaypoints];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL * urlApi = [NSURL URLWithString:urlString];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:urlApi];
    
    NSError * erro = nil;
    
    NSData * response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&erro];
    
    if (erro) {
        NSLog(@"Erro: %@",erro);
        return nil;
    }
    
    id json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&erro];
    id pontosEncodedObject;
    NSString * pontosEncoded;
    
    if ([json respondsToSelector:@selector(objectForKey:)]) {
        //        NSLog(@"Json - %@",json);
        id rotas = [json objectForKey:@"routes"];
        
        if ([rotas respondsToSelector:@selector(objectForKey:)]) {
            
            pontosEncodedObject = [rotas objectForKey:@"overview_polyline"];
            
        } else if ([rotas respondsToSelector:@selector(objectAtIndex:)]) {
            
            pontosEncodedObject = [[rotas objectAtIndex:0] objectForKey:@"overview_polyline"];
            
        }
        
        if ([pontosEncodedObject respondsToSelector:@selector(objectForKey:)]) {
            pontosEncoded = [pontosEncodedObject objectForKey:@"points"];
        }
        
        //        NSLog(@"%@",pontosEncoded);
        //        pontosEncoded = [[[json objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"];        
    }
    
	return [self decodePolyLine:[pontosEncoded mutableCopy]];
}

#pragma Mark - Metodos Publicos

- (void) exibeRotaDe:(CLLocationCoordinate2D) pontoOrigem ate:(CLLocationCoordinate2D) pontoDestino comWaypoints:(NSArray*) waypoints {
    
    NSArray * pontos = [self buscarListaDePontosDaRotaComOrigem:pontoOrigem eDestino:pontoDestino comWaypoints:waypoints];
    
	MKMapPoint northEastPoint; 
	MKMapPoint southWestPoint; 
	
	// criar um array de pontos em C
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * pontos.count);
	
	for(int idx = 0; idx < pontos.count; idx++)
	{

        CLLocation * loc = (CLLocation*) [pontos objectAtIndex:idx];

        // criar o ponto de rota a partir da coordenada
		MKMapPoint point = MKMapPointForCoordinate(loc.coordinate);
		//
		// ajustar a bounding box
		//
		
		// se for o primeiro ponto o usamos, pois nao temos com o que compara ainda 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		}
		else 
		{
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
        
		pointArr[idx] = point;
        
	}
    
	// criar a rota a ser exibida a partir do array de pontos 
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:pontos.count];
	_routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    
	// limpar a memoria
	free(pointArr);
    
    if (self.routeLine) {
        [self.mapView addOverlay:self.routeLine];
        [self.mapView setVisibleMapRect:self.routeRect];
        
        for (NSDictionary * intermediario in waypoints) {
            AnnotationPonto * pontoIntermediario = [AnnotationPonto new];
            pontoIntermediario.coordinate = CLLocationCoordinate2DMake([[intermediario objectForKey:@"latitude"] floatValue], [[intermediario objectForKey:@"longitude"] floatValue]);
            pontoIntermediario.title = [NSString stringWithFormat:@"Ponto intermediario %d",[waypoints indexOfObject:intermediario]+1];
            [self.mapView addAnnotation:pontoIntermediario];
        }
    }
}

@end
