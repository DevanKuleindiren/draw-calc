//
//  Matrix+NeuralNetExtension.h
//  Draw
//
//  Created by Devan Kuleindiren on 18/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"

@interface Matrix (Matrix_NeuralNetExtension)

- (Matrix *) addBiasColumn;
- (void) activationFunctionWithBeta:(double)beta;
- (void) rectifyActivations;

@end
