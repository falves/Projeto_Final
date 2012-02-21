//
//  ViewController.h
//  Projeto_Final
//
//  Created by Felipe Alves on 20/02/12.
//  Copyright (c) 2012 Bitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define KM 0.009

@interface ViewController : UIViewController <MKMapViewDelegate>
{
    BOOL primeiraPosicao;
    MKMapView * _mapView;
}

@property (nonatomic, assign, getter=isPrimeiraPosicao) BOOL primeiraPosicao;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

- (void) exibeAnnotationComLatitude:(NSString*)latitude ELongitude:(NSString*)longitude EiD:(NSString*)idPonto;

@end
