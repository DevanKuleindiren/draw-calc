//
//  DeepNet.h
//  Draw
//
//  Created by Devan Kuleindiren on 14/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"
#import "Matrix+NeuralNetExtension.h"

@interface DeepNet : NSObject {
    
    Matrix *weights1;
    Matrix *weights2;
}

@property (readonly) int inputNodesNo;
@property (readonly) int hiddenNeuronNo;
@property (readonly) int outputNeuronNo;

- (id) initWithInputNodes:(int)noOfInputNodes hiddenNeurons:(int)noOfHiddenNeurons outputNeurons:(int)noOfOutputNeurons;
- (Matrix *) useNetWithInputs:(Matrix *)inputVectors andBeta:(double)beta;
- (Matrix *) rectifyActivations:(Matrix *)mtx;

@end
