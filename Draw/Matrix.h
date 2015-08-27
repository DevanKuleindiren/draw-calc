//
//  Matrix.h
//  Draw
//
//  Created by Devan Kuleindiren on 15/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Matrix : NSObject {
    
    NSMutableArray *matrix;
}

@property (readonly) int rows;
@property (readonly) int cols;

- (Matrix *) initWithRows:(int)noRows cols:(int)noCols;
- (void) insertObjectAtRow:(int)row col:(int)col obj:(id)obj;
- (NSNumber *) row:(int)row col:(int)col;
- (Matrix *) transpose;
- (Matrix *) multiply:(Matrix *)mtx;
- (Matrix *) add:(Matrix *)mtx;
- (Matrix *) subtract:(Matrix *)mtx;
- (Matrix *) scalarMultiply:(double)scalar;
- (void) printMatrix;
- (void) printMatrixIntValue;
- (void) printMatrixIntValueFlat;

@end
