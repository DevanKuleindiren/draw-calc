//
//  FNN3Layer.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 27/09/2015.
//  Copyright © 2015 Devan Kuleindiren. All rights reserved.
//

#import "FNN3Layer.h"

@interface FNN3Layer ()

- (void) initWeights:(NSString *)fileString;
- (Matrix *) useNetP1WithInputs:(Matrix *)inputVectors andBeta:(double)beta;
- (Matrix *) useNetP2WithHiddenActs1:(Matrix *)hiddenActs1 andBeta:(double)beta;
- (Matrix *) useNetP3WithHiddenActs2:(Matrix *)hiddenActs2 andBeta:(double)beta;

@end

@implementation FNN3Layer

- (id) initWithInputNodes:(int)noOfInputNodes hiddenNeurons1:(int)noOfHiddenNeurons1 hiddenNeurons2:(int)noOfHiddenNeurons2 outputNeurons:(int)noOfOutputNeurons {
    self = [super init];
    
    if (self) {
        _inputNodesNo = noOfInputNodes;
        _hiddenNeuronNo1 = noOfHiddenNeurons1;
        _hiddenNeuronNo2 = noOfHiddenNeurons2;
        _outputNeuronNo = noOfOutputNeurons;
        
        weightsIH = [[Matrix alloc] initWithRows:_inputNodesNo cols:_hiddenNeuronNo1];
        weightsHH = [[Matrix alloc] initWithRows:(_hiddenNeuronNo1 + 1) cols:_hiddenNeuronNo2];
        weightsHO = [[Matrix alloc] initWithRows:(_hiddenNeuronNo2 + 1) cols:_outputNeuronNo];
        
        NSError *error;
        NSString *myPath = [[NSBundle mainBundle]pathForResource:@"w14000x2000x0001" ofType:@"txt"];
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
    NSString *weightsIHString = lines[1];
    NSString *weightsHHString = lines[2];
    NSString *weightsHOString = lines[3];
    
    NSArray *weightsIHComponents = [weightsIHString componentsSeparatedByString:@","];
    NSArray *weightsHHComponents = [weightsHHString componentsSeparatedByString:@","];
    NSArray *weightsHOComponents = [weightsHOString componentsSeparatedByString:@","];
    
    for (int row = 0; row < weightsIH.rows; row++) {
        for (int col = 0; col < weightsIH.cols; col++) {
            [weightsIH insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:([weightsIHComponents[(row * weightsIH.cols) + col] doubleValue])]];
        }
    }
    
    for (int row = 0; row < weightsHH.rows; row++) {
        for (int col = 0; col < weightsHH.cols; col++) {
            [weightsHH insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:([weightsHHComponents[(row * weightsHH.cols) + col] doubleValue])]];
        }
    }
    
    for (int row = 0; row < weightsHO.rows; row++) {
        for (int col = 0; col < weightsHO.cols; col++) {
            [weightsHO insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:([weightsHOComponents[(row * weightsHO.cols) + col] doubleValue])]];
        }
    }
}

- (Matrix *) rectifyActivations:(Matrix *)mtx {
    [mtx rectifyActivations];
    return mtx;
}

- (Matrix *) useNetWithInputs:(Matrix *)inputVectors andBeta:(double)beta {
    
    Matrix *hiddenActs1 = [self useNetP1WithInputs:inputVectors andBeta:beta];
    Matrix *hiddenActs2 = [self useNetP2WithHiddenActs1:hiddenActs1 andBeta:beta];
    Matrix *outputActs = [self useNetP3WithHiddenActs2:hiddenActs2 andBeta:beta];
    
    return outputActs;
}

- (Matrix *) useNetP1WithInputs:(Matrix *)inputVectors andBeta:(double)beta {
    Matrix *hiddenActs1WithoutBias = [inputVectors multiply:weightsIH];
    [hiddenActs1WithoutBias activationFunctionWithBeta:beta];
    Matrix *hiddenActs1 = [hiddenActs1WithoutBias addBiasColumn];
    
    return hiddenActs1;
}

- (Matrix *) useNetP2WithHiddenActs1:(Matrix *)hiddenActs1 andBeta:(double)beta {
    Matrix *hiddenActs2WithoutBias = [hiddenActs1 multiply:weightsHH];
    [hiddenActs2WithoutBias activationFunctionWithBeta:beta];
    Matrix *hiddenActs2 = [hiddenActs2WithoutBias addBiasColumn];
    
    return hiddenActs2;
}

- (Matrix *) useNetP3WithHiddenActs2:(Matrix *)hiddenActs2 andBeta:(double)beta {
    Matrix *outputActs = [hiddenActs2 multiply:weightsHO];
    [outputActs activationFunctionWithBeta:beta];
    
    return outputActs;
}



@end

