//
//  ViewController.m
//  Projeto_Final
//
//  Created by Felipe Alves on 20/02/12.
//  Copyright (c) 2012 Bitix. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize primeiraPosicao;
@synthesize usuarioLocalizadoPelaPrimeiraVez;
@synthesize pontosSendoExibidos = _pontosSendoExibidos;
@synthesize mapView = _mapView;
@synthesize mapViewDelegate = _mapViewDelegate;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.primeiraPosicao = YES;
    //self.primeiraBuscaDePontos = YES;
    
    self.mapViewDelegate = [BUSMapViewDelegate new];
    [self.mapView setDelegate:self.mapViewDelegate];
    self.mapViewDelegate.mapView = self.mapView;
    
    AnnotationPonto * anotOrigem = [AnnotationPonto new];
	anotOrigem.title = @"Origem";
	anotOrigem.subtitle = @"Ponto inicial";
    anotOrigem.coordinate = CLLocationCoordinate2DMake(-22.960414, -43.205895);
	
    AnnotationPonto * anotDestino = [AnnotationPonto new];
	anotDestino.title = @"Destino";
	anotDestino.subtitle = @"Ponto final";
    anotDestino.coordinate = CLLocationCoordinate2DMake(-22.962789, -43.207386);

    
    [self.mapView addAnnotation:anotOrigem];
    [self.mapView addAnnotation:anotDestino];

    NSDictionary * ponto1 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-22.960994",@"-43.206705", nil] forKeys:[NSArray arrayWithObjects:@"latitude",@"longitude", nil]];
    NSDictionary * ponto2 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-22.96211",@"-43.21000", nil] forKeys:[NSArray arrayWithObjects:@"latitude",@"longitude", nil]];
    NSDictionary * ponto3 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-22.962130",@"-43.207257", nil] forKeys:[NSArray arrayWithObjects:@"latitude",@"longitude", nil]];
    
    NSArray * waypoints = [NSArray arrayWithObjects:ponto1,ponto2,ponto3, nil];
    
    CLLocationCoordinate2D origem = CLLocationCoordinate2DMake(-22.960414, -43.205895);
    CLLocationCoordinate2D destino = CLLocationCoordinate2DMake(-22.962789, -43.207386);

    [self.mapViewDelegate exibeRotaDe:origem ate:destino comWaypoints:waypoints];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma Mark - MapView Delegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
//    if (self.isPrimeiraPosicao) {
//        
//        MKCoordinateRegion region;
//        region.center = userLocation.coordinate;  
//        
//        MKCoordinateSpan span; 
//        span.latitudeDelta  = 1 * KM;
//        span.longitudeDelta = 1 * KM; 
//        region.span = span;
//        
//        [self.mapView setRegion:region animated:YES];
//        
//        self.primeiraPosicao = NO;
//        
//        // Utilizamos um delay de 3 segundos para dar tempo do mapa dar um zoom na posicao encontrada
//        [self performSelector:@selector(buscaPontosNoMapaExibido) withObject:nil afterDelay:3];
//    }
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
        
    // So tentamos buscar pontos no mapa se tivermos internet e se o usuario ja tiver sido localizado
    if ((ReachableViaWiFi || ReachableViaWWAN) && self.isUsuarioLocalizadoPelaPrimeiraVez) {
        [self buscaPontosNoMapaExibido];
    }
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *annoView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
                   
                                                                    reuseIdentifier:@"current"];
    annoView.animatesDrop = YES;
    annoView.canShowCallout = YES;
    annoView.pinColor = MKPinAnnotationColorGreen;
    
    AnnotationPonto * anno = (AnnotationPonto*) annotation;
//    NSLog(@"Titulo: %@",anno.idPonto);
    UIButton * botaoDireito = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [botaoDireito setTitle:anno.idPonto forState:UIControlStateNormal];
    [botaoDireito addTarget:self action:@selector(exibeDetalhesDoPonto:) forControlEvents:UIControlEventTouchUpInside];
    annoView.rightCalloutAccessoryView = botaoDireito;
    return annoView;
}

#pragma Mark - Metodos Auxiliares

- (void) exibeAnnotationComLatitude:(NSString*)latitude ELongitude:(NSString*)longitude EiD:(NSString*)idPonto {
//    NSLog(@"Recebidos: Latitude = %@, Longitude = %@, id = %@",latitude,longitude,idPonto);
    
    // Se o ponto ainda nao esta sendo exibido, o adicionamos ao mapa e ao array de pontos sendo exibidos. Isso evita reposicionar pontos que ja estao no mapa.
    
    if (![self pontoJaEstaNoMapa:idPonto]) {
        AnnotationPonto * ponto = [[AnnotationPonto alloc] init];
        CLLocationCoordinate2D coordenada;
        
        coordenada.latitude = latitude.floatValue;
        coordenada.longitude = longitude.floatValue;
        
        ponto.coordinate = coordenada;
        ponto.idPonto = idPonto;
        ponto.title = @"Ponto";
        ponto.subtitle = idPonto;
        
        [self.pontosSendoExibidos addObject:idPonto];
        
        [self.mapView addAnnotation:ponto];

    }
    
}

- (void) buscaPontosNoMapaExibido {
    
//    NSLog(@"Buscou pontos.");
    
    // A primeira entrada nesse metodo so ocorre depois do ususario ter sido localizado, logo, alteramos a propriedade para indicar isso
    if (!self.isUsuarioLocalizadoPelaPrimeiraVez) {
        self.usuarioLocalizadoPelaPrimeiraVez = YES;
    }
    
    NSString * enderecoDoWebservice = [NSString stringWithFormat:@"%@/",SERVIDOR];
    
    // Calculamos as latitudes e longitudes maximas e minimas para definir qual area esta sendo exibida e buscar os pontos dentro dela
    
    NSString * latitudeMaxima = [NSString stringWithFormat:@"%f", (self.mapView.region.center.latitude + self.mapView.region.span.latitudeDelta)];
    NSString * latitudeMinima = [NSString stringWithFormat:@"%f", (self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta)];
    
    NSString * longitudeMaxima = [NSString stringWithFormat:@"%f", (self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta)];
    NSString * longitudeMinima = [NSString stringWithFormat:@"%f", (self.mapView.region.center.longitude + self.mapView.region.span.longitudeDelta)];
    
    NSString * enderecoComParametros = [NSString stringWithFormat:@"%@/ConsultaPontosNaArea?latitudeMaxima=%@&latitudeMinima=%@&longitudeMaxima=%@&longitudeMinima=%@",enderecoDoWebservice,latitudeMaxima,latitudeMinima,longitudeMaxima,longitudeMinima];
    //NSLog(@"%@",enderecoComParametros);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:enderecoComParametros]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (error) {
            NSLog(@"Deu erro.");
            return;
        }
        
        //NSLog(@"Sucesso!");
        
        NSDictionary * pontos = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
        
        //NSLog(@"Array - %@",pontos);
        
        for (NSDictionary * dict in pontos) {
            [self exibeAnnotationComLatitude:[dict objectForKey:@"latitude"] ELongitude:[dict objectForKey:@"longitude"] EiD:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
        }
        
    }];

}

- (BOOL) pontoJaEstaNoMapa:(NSString*)ponto {
    
    for (NSString* pontoDoArray in self.pontosSendoExibidos) {
        if ([pontoDoArray isEqualToString:ponto]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSMutableArray*) pontosSendoExibidos {
    
    if (!_pontosSendoExibidos) {
        _pontosSendoExibidos = [NSMutableArray new];
    }
    
    return _pontosSendoExibidos;
    
}

- (void) exibeDetalhesDoPonto:(UIButton*)pontoAnnotation {
    
    NSString * idPonto = [pontoAnnotation titleForState:UIControlStateNormal];
    
    NSLog(@"Clicou: %@",idPonto);
}


@end
