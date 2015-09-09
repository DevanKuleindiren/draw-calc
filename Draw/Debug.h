//
//  Debug.h
//  Draw Calc
//
//  Created by Devan Kuleindiren on 08/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Debug : NSObject

+ (void) drawRectBoundsWithLooseRect:(CGRect)looseRect tightRect:(CGRect)tightRect onImageView:(UIImageView *)iV inViewController:(UIViewController *)vC;

@end
