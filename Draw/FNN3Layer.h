//
//  FNN3Layer.h
//  Draw Calc
//
//  Created by Devan Kuleindiren on 27/09/2015.
//  Copyright © 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"
#import "Matrix+NeuralNetExtension.h"

@interface FNN3Layer : NSObject {
    
    Matrix *weightsIH;
    Matrix *weightsHH;
    Matrix *weightsHO;
}

@property (readonly) int inputNodesNo;
@property (readonly) int hiddenNeuronNo1;
@property (readonly) int hiddenNeuronNo2;
@property (readonly) int outputNeuronNo;

- (id) initWithInputNodes:(int)noOfInputNodes hiddenNeurons1:(int)noOfHiddenNeurons1 hiddenNeurons2:(int)noOfHiddenNeurons2 outputNeurons:(int)noOfOutputNeurons;
- (Matrix *) useNetWithInputs:(Matrix *)inputVectors andBeta:(double)beta;
- (Matrix *) rectifyActivations:(Matrix *)mtx;

@end