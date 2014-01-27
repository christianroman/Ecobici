//
//  CalloutView.m
//  Ecobici
//
//  Created by Christian Roman on 26/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "CalloutView.h"
#import "UIColor+Utilities.h"

@import QuartzCore;

@interface CalloutView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImage *backgroundImage;

@end

@implementation CalloutView

- (id)initWithFrame:(CGRect)frame bikes:(NSNumber *)bikes free:(NSNumber *)free name:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _backgroundImage = [UIImage imageNamed:@"callout_bg"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_backgroundImage];
        [self addSubview:imageView];
        
        _bikesLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 8, 35, 25)];
        [_bikesLabel setText:[NSString stringWithFormat:@"%@", bikes ? bikes : @"-"]];
        [_bikesLabel setTextColor:[UIColor colorWithHex:0x404040]];
        [_bikesLabel setFont:[UIFont boldSystemFontOfSize:26.0f]];
        [_bikesLabel setMinimumScaleFactor:0.4];
        [_bikesLabel sizeToFit];
        [self addSubview:_bikesLabel];
        
        _freeLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 8, 35, 25)];
        [_freeLabel setText:[NSString stringWithFormat:@"%@", free ? free : @"-"]];
        [_freeLabel setTextColor:[UIColor colorWithHex:0x404040]];
        [_freeLabel setFont:[UIFont boldSystemFontOfSize:26.0f]];
        [_freeLabel setMinimumScaleFactor:0.4];
        [_freeLabel sizeToFit];
        [self addSubview:_freeLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 165, 18)];
        [_nameLabel setText:[NSString stringWithFormat:@"%@", name]];
        [_nameLabel setTextColor:[UIColor colorWithHex:0x50b948]];
        [_nameLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setAdjustsFontSizeToFitWidth:YES];
        [_nameLabel setMinimumScaleFactor:0.4];
        [self addSubview:_nameLabel];
        
    }
    return self;
}

@end
