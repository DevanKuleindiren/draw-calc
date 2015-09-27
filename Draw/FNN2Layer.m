//
//  FNN3Layer.m
//  Draw
//
//  Created by Devan Kuleindiren on 14/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "FNN2Layer.h"

@interface FNN2Layer ()

- (void) initWeights:(NSString *)fileString;
- (Matrix *) useNetP1WithInputs:(Matrix *)inputVectors andBeta:(double)beta;
- (Matrix *) useNetP2WithHiddenActs:(Matrix *)hiddenActs andBeta:(double)beta;

@end

@implementation FNN2Layer

- (id) initWithInputNodes:(int)noOfInputNodes hiddenNeurons:(int)noOfHiddenNeurons outputNeurons:(int)noOfOutputNeurons {
    self = [super init];
    
    if (self) {
        _inputNodesNo = noOfInputNodes;
        _hiddenNeuronNo = noOfHiddenNeurons;
        _outputNeuronNo = noOfOutputNeurons;
        
        weights1 = [[Matrix alloc] initWithRows:_inputNodesNo cols:_hiddenNeuronNo];
        weights2 = [[Matrix alloc] initWithRows:(_hiddenNeuronNo + 1) cols:_outputNeuronNo];
        
        NSError *error;
        NSString *myPath = [[NSBundle mainBundle]pathForResource:@"w14000x1000x0001" ofType:@"txt"];
        NSString *stringFromWeights = [[NSString alloc] initWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:&error];
        
        if (stringFromWeights == nil) NSLog(@"Error.");
        else {
            [self initWeights:stringFromWeights];
        }
    }
    
    return self;
}

- (void) initWeights:(NSString *)fileString {
    NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
    NSString *weights1String = lines[1];
    NSString *weights2String = lines[2];

    NSArray *weights1Components = [weights1String componentsSeparatedByString:@","];
    NSArray *weights2Components = [weights2String componentsSeparatedByString:@","];
    
    for (int row = 0; row < weights1.rows; row++) {
        for (int col = 0; col < weights1.cols; col++) {
            [weights1 insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:([weights1Components[(row * weights1.cols) + col] doubleValue])]];
        }
    }
    
    for (int row = 0; row < weights2.rows; row++) {
        for (int col = 0; col < weights2.cols; col++) {
            [weights2 insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:([weights2Components[(row * weights2.cols) + col] doubleValue])]];
        }
    }
}

- (Matrix *) rectifyActivations:(Matrix *)mtx {
    [mtx rectifyActivations];
    return mtx;
}

- (Matrix *) useNetWithInputs:(Matrix *)inputVectors andBeta:(double)beta {
    
    Matrix *hiddenActs = [self useNetP1WithInputs:inputVectors andBeta:beta];
    Matrix *outputActs = [self useNetP2WithHiddenActs:hiddenActs andBeta:beta];
    
    return outputActs;
}

- (Matrix *) useNetP1WithInputs:(Matrix *)inputVectors andBeta:(double)beta {
    Matrix *hiddenActsWithoutBias = [inputVectors multiply:weights1];
    [hiddenActsWithoutBias activationFunctionWithBeta:beta];
    Matrix *hiddenActs = [hiddenActsWithoutBias addBiasColumn];
    
    return hiddenActs;
}

- (Matrix *) useNetP2WithHiddenActs:(Matrix *)hiddenActs andBeta:(double)beta {
    Matrix *outputActs = [hiddenActs multiply:weights2];
    [outputActs activationFunctionWithBeta:beta];
    
    return outputActs;
}



@end
