//
//  UIImage+UIImage_PixelInteraction.h
//  Draw Calc
//
//  Created by Devan Kuleindiren on 09/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Matrix.h"
#import "Matrix+NeuralNetExtension.h"

@interface UIImage (UIImage_PixelInteraction)

- (Matrix *) extractRawImageDataFromX:(int)x fromY:(int)y with28Multiple:(int)multiple andInputNodesNo:(int)inputNodesNo;

@end
