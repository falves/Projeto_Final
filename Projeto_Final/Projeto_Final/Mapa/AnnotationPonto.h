//
//  AnnotationPonto.h
//  Projeto_Final
//
//  Created by Felipe Alves on 21/02/12.
//  Copyright (c) 2012 Bitix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationPonto : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D  coordinate;
    NSString                * title;
    NSString                * subtitle;
    NSString                * idPonto;
    BOOL                    inicio;
    BOOL                    fim;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *idPonto;
@property (nonatomic, assign, getter=isInicio) BOOL inicio;
@property (nonatomic, assign, getter=isFim) BOOL fim;

@end
