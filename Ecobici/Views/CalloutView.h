//
//  CalloutView.h
//  Ecobici
//
//  Created by Christian Roman on 26/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalloutView : UIView

@property (nonatomic, strong) UILabel *bikesLabel;
@property (nonatomic, strong) UILabel *freeLabel;
@property (nonatomic, strong) UILabel *nameLabel;

- (id)initWithFrame:(CGRect)frame bikes:(NSNumber *)bikes free:(NSNumber *)free name:(NSString *)name;

@end
