//
//  ViewController.h
//  Projeto_Final
//
//  Created by Felipe Alves on 20/02/12.
//  Copyright (c) 2012 Bitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AnnotationPonto.h"
#import "BUSMapViewDelegate.h"

#define KM 0.009

@interface ViewController : UIViewController <MKMapViewDelegate>
{
    BOOL primeiraPosicao;
    BOOL usuarioLocalizadoPelaPrimeiraVez;
    MKMapView * _mapView;
    NSMutableArray * _pontosSendoExibidos;
}

@property (nonatomic, assign, getter=isPrimeiraPosicao) BOOL primeiraPosicao;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, assign, getter=isUsuarioLocalizadoPelaPrimeiraVez) BOOL usuarioLocalizadoPelaPrimeiraVez;
@property (nonatomic, strong) NSMutableArray *pontosSendoExibidos;
@property (nonatomic, strong) BUSMapViewDelegate * mapViewDelegate;

- (void) exibeAnnotationComLatitude:(NSString*)latitude ELongitude:(NSString*)longitude EiD:(NSString*)idPonto;
- (void) buscaPontosNoMapaExibido;
- (BOOL) pontoJaEstaNoMapa:(NSString*)ponto;
- (void) exibeDetalhesDoPonto:(UIButton*)pontoAnnotation;

@end
