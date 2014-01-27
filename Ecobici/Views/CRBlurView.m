//
//  CRBlurView.m
//  Gradients
//
//  Created by Christian Roman on 13/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

//
//  AMBlurView.m
//  blur
//
//  Created by Cesar Pinto Castillo on 7/1/13.
//  Copyright (c) 2013 Arctic Minds Inc. All rights reserved.
//

#import "CRBlurView.h"

@import QuartzCore;

@interface CRBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation CRBlurView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setClipsToBounds:YES];
    if (![self toolbar]) {
        [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
        [self.layer insertSublayer:[self.toolbar layer] atIndex:0];
    }
}

- (void) setBlurTintColor:(UIColor *)blurTintColor
{
    [self.toolbar setBarTintColor:blurTintColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.toolbar setFrame:[self bounds]];
}

@end
