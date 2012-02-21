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
@synthesize mapView = _mapView;


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
    
    if (self.isPrimeiraPosicao) {
        
        MKCoordinateRegion region;
        region.center = userLocation.coordinate;  
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = 1 * KM;
        span.longitudeDelta = 1 * KM; 
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
        
        self.primeiraPosicao = NO;
    }
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (!self.isPrimeiraPosicao) {
        NSLog(@"Buscar mais pontos");
    }
    
    if (ReachableViaWiFi || ReachableViaWWAN) {
        
        NSString * enderecoDoWebservice = [NSString stringWithFormat:@"%@/",SERVIDOR];
        
        NSString * latitudeMaxima = [NSString stringWithFormat:@"%f", (mapView.region.center.latitude + mapView.region.span.latitudeDelta)];
        NSString * latitudeMinima = [NSString stringWithFormat:@"%f", (mapView.region.center.latitude - mapView.region.span.latitudeDelta)];
        
        NSString * longitudeMaxima = [NSString stringWithFormat:@"%f", (mapView.region.center.longitude - mapView.region.span.longitudeDelta)];
        NSString * longitudeMinima = [NSString stringWithFormat:@"%f", (mapView.region.center.longitude + mapView.region.span.longitudeDelta)];
         
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
                [self exibeAnnotationComLatitude:[dict objectForKey:@"latitude"] ELongitude:[dict objectForKey:@"longitude"] EiD:[dict objectForKey:@"id"]];
            }
            
        }];
                                         
    }
    
}

#pragma Mark - Metodos Auxiliares

- (void) exibeAnnotationComLatitude:(NSString*)latitude ELongitude:(NSString*)longitude EiD:(NSString*)idPonto {
    NSLog(@"Recebidos: Latitude = %@, Longitude = %@, id = %@",latitude,longitude,idPonto);
}

@end
