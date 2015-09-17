//
//  Matrix.m
//  Draw
//
//  Created by Devan Kuleindiren on 15/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "Matrix.h"

@interface Matrix()

- (NSMutableArray *) row:(int)row;
- (Matrix *) addTract:(Matrix *)mtx isAddition:(BOOL)isAdd;

@end

@implementation Matrix

@synthesize matrix;

- (void) insertObjectAtRow:(int)row col:(int)col obj:(id)obj {
    @try {
        [matrix[row] replaceObjectAtIndex:col withObject:obj];
    }
    @catch (NSException *exception) {
        [matrix[row] insertObject:obj atIndex:col];
    }
    @finally {
        
    }
}

- (NSNumber *) row:(int)row col:(int)col {
    return matrix[row][col];
}

- (NSMutableArray *) row:(int)row {
    return matrix[row];
}

- (Matrix *) initWithRows:(int)noRows cols:(int)noCols {
    self = [super init];
    
    if (self) {
        _rows = noRows;
        _cols = noCols;
        
        matrix = [NSMutableArray arrayWithCapacity:noRows];
        for (int i = 0; i < noRows; i++) {
            [matrix insertObject:[NSMutableArray arrayWithCapacity:noCols] atIndex:i];
        }
    }
    
    return self;
}

- (Matrix *) transpose {
    Matrix *m = [[Matrix alloc] initWithRows:_cols cols:_rows];
    
    for (int row = 0; row < _cols; row++) {
        for (int col = 0; col < _rows; col++) {
            [m insertObjectAtRow:row col:col obj:matrix[col][row]];
        }
    }
    return m;
}

- (Matrix *) multiply:(Matrix *)mtx {
    if (_cols != mtx.rows) return nil;
    
    Matrix *m = [[Matrix alloc] initWithRows:_rows cols:mtx.cols];
    
    for (int row = 0; row < _rows; row++) {
        for (int col = 0; col < mtx.cols; col++) {
            double temp = 0;
            for (int i = 0; i < _cols; i++) {
                temp += [matrix[row][i] doubleValue] * [[mtx row:i col:col] doubleValue];
            }
            NSNumber *n = [NSNumber numberWithDouble:temp];
            [[m row:row] insertObject:n atIndex:col];
        }
    }
    
    return m;
}

- (Matrix *) add:(Matrix *)mtx {
    return [self addTract:mtx isAddition:YES];
}

- (Matrix *) subtract:(Matrix *)mtx {
    return [self addTract:mtx isAddition:NO];
}

- (Matrix *) addTract:(Matrix *)mtx isAddition:(BOOL)isAdd {
    if (mtx.rows != _rows || mtx.cols != _cols) return nil;
    
    Matrix *m = [[Matrix alloc] initWithRows:_rows cols:_cols];
    
    for (int row = 0; row < _rows; row++) {
        for (int col = 0; col < _cols; col++) {
            NSNumber *n = [NSNumber numberWithDouble:0];
            if (isAdd) n = [NSNumber numberWithDouble:([matrix[row][col] doubleValue] + [[mtx row:row col:col] doubleValue])];
            else n = [NSNumber numberWithDouble:([matrix[row][col] doubleValue] - [[mtx row:row col:col] doubleValue])];
            [[m row:row] insertObject:n atIndex:col];
        }
    }
    
    return m;
}

- (Matrix *) scalarMultiply:(double)scalar {
    Matrix *m = [[Matrix alloc] initWithRows:_rows cols:_cols];
    
    for (int row = 0; row < _rows; row++) {
        for (int col = 0; col < _cols; col++) {
            NSNumber *n = [NSNumber numberWithDouble:([matrix[row][col] doubleValue] * scalar)];
            [[m row:row] insertObject:n atIndex:col];
        }
    }
    
    return m;
}

@end
