//
//  Matrix+NeuralNetExtension.m
//  Draw
//
//  Created by Devan Kuleindiren on 18/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "Matrix+NeuralNetExtension.h"

@implementation Matrix (Matrix_NeuralNetExtension)

const double E = 2.718281828459045235;

- (Matrix *) addBiasColumn {
    Matrix *m = [[Matrix alloc] initWithRows:self.rows cols:(self.cols + 1)];
    
    for (int row = 0; row < self.rows; row++) {
        for (int col = 0; col < self.cols; col++) {
            [m insertObjectAtRow:row col:col obj:[self row:row col:col]];
        }
    }
    
    for (int row = 0; row < self.rows; row++) {
        [m insertObjectAtRow:row col:self.cols obj:[NSNumber numberWithDouble:-1]];
    }
    
    return m;
}

- (void) activationFunctionWithBeta:(double)beta {
    for (int row = 0; row < self.rows; row++) {
        for (int col = 0; col < self.cols; col++) {
            [self insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:(1.0 / (1 + pow(E, -beta * [[self row:row col:col] doubleValue])))]];
        }
    }
}

- (void) rectifyActivations {
    for (int row = 0; row < self.rows; row++) {
        double tempMax = [[self row:row col:0] doubleValue];
        int tempMaxPos = 0;
        for (int col = 0; col < self.cols; col++) {
            if ([[self row:row col:col] doubleValue] > tempMax) {
                tempMax = [[self row:row col:col] doubleValue];
                tempMaxPos = col;
            }
            [self insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:0]];
        }
        [self insertObjectAtRow:row col:tempMaxPos obj:[NSNumber numberWithDouble:1.0]];
    }
}

@end
