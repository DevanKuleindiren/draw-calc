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
#import "Pixel.h"
#import "PixelQueue.h"

@interface UIImage (UIImage_PixelInteraction)

- (unsigned char *) extractRawImageData;
- (Matrix *) extractInputVectorFromRawData:(unsigned char *)rawData fromX:(int)x fromY:(int)y with28Multiple:(int)multiple inputNodesNo:(int)inputNodesNo labelEncoding:(unsigned long int)labelEncoding;
- (unsigned long int *) labelConnectedComponentsIn:(unsigned char *) rawData;

@end
