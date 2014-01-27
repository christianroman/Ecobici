//
//  StationAnnotationView.m
//  Ecobici
//
//  Created by Christian Roman on 26/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "StationAnnotationView.h"

@implementation StationAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        
        // NSNotificacion y mostrar el calloutView
        
    } else {
        
        // NSNotification y ocultar el calloutView
        
    }
}

@end
