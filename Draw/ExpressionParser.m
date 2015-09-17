//
//  ExpressionParser.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 16/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "ExpressionParser.h"

@interface ExpressionParser()

+ (BOOL) isExpressionValid:(NSString *) expression;
+ (NSMutableString *) evalBinaryOperator:(NSMutableString *)operator arg1:(NSMutableString *)arg1 arg2:(NSMutableString *)arg2;
+ (BOOL) checkIf:(NSMutableString *)op1 hasHigherPrecedenceThan:(NSMutableString *)op2;

@end

@implementation ExpressionParser

+ (NSString *) parseExpressionWithNoBrackets:(NSString *) expression {
    
    // Check that expression is valid
    if (![self isExpressionValid:expression]) {
        return nil;
    }
    
    // Prepare array for storing 'units' - i.e. a number or an operator
    int noOfUnits = (int) [expression length]; // For now, this is an upper bound
    NSMutableString *units[noOfUnits];
    for (int s = 0; s < noOfUnits; s++) {
        units[s] = [[NSMutableString alloc] initWithString:@""];
    }
    
    // Extract the numbers & symbols from the expression
    BOOL prevWasNumber = YES;
    int unitIndex = 0;
    for (int c = 0; c < [expression length]; c++) {
        char character = [expression characterAtIndex:c];
        BOOL currentIsNumber = character >= '0' && character <= '9';
        BOOL currentIsMinus = character == '-';
        
        if ((currentIsNumber && !prevWasNumber) || (currentIsMinus && !prevWasNumber)) {
            prevWasNumber = YES;
            unitIndex++;
        }
        else if ((!currentIsNumber && !currentIsMinus) || (currentIsMinus && prevWasNumber && c != 0)) {
            prevWasNumber = NO;
            unitIndex++;
        }
        [units[unitIndex] appendFormat:@"%c", character];
    }
    noOfUnits = unitIndex + 1; // Now, noOfUnits is exact
    
    // In theory, by this point, the units array should be: number, symbol, number, symbol, etc.
    BOOL isNumber = YES;
    MutableStringStack *operators = [[MutableStringStack alloc] init];
    MutableStringStack *operands = [[MutableStringStack alloc] init];
    for (int u = noOfUnits - 1; u >= 0; u--) {
        if (isNumber) {
            [operands push:units[u]];
        } else {
            if ([self checkIf:[operators head] hasHigherPrecedenceThan:units[u]]) {
                NSMutableString *arg1 = [operands pop];
                NSMutableString *arg2 = [operands pop];
                NSMutableString *operator = [operators pop];
                NSMutableString *answer = [self evalBinaryOperator:operator arg1:arg1 arg2:arg2];
                if ([answer isEqualToString:@"NaN"]) return @"NaN";
                [operands push:answer];
            }
            [operators push:units[u]];
        }
        isNumber = !isNumber;
    }
    
    // Now, work back down the stacks
    while (![operators isEmpty]) {
        NSMutableString *arg1 = [operands pop];
        NSMutableString *arg2 = [operands pop];
        NSMutableString *operator = [operators pop];
        [operands push:[self evalBinaryOperator:operator arg1:arg1 arg2:arg2]];
    }
    
    // Finally, replace 'd' with the real division sign, and append the result
    NSError *error2 = NULL;
    NSRegularExpression *divisionRegex = [NSRegularExpression regularExpressionWithPattern:@"d" options:NSRegularExpressionCaseInsensitive error:&error2];
    NSMutableString *result = [NSMutableString stringWithString:[divisionRegex stringByReplacingMatchesInString:expression options:0 range:NSMakeRange(0, [expression length]) withTemplate:@"\u00F7"]];
    [result appendString:[NSString stringWithFormat:@" = %.02f", [[operands pop] doubleValue]]];
    
    return result;
}

+ (BOOL) isExpressionValid:(NSString *) expression {
    
    // Check it's non-empty
    if ([expression length] == 0) {
        return NO;
    }
    
    // Check first character is a digit or a minus sign
    char firstChar = [expression characterAtIndex:0];
    if ((firstChar < '0' || firstChar > '9') && firstChar != '-') {
        return NO;
    }
    char lastChar = [expression characterAtIndex:[expression length] - 1];
    if (lastChar < '0' || lastChar > '9') {
        return NO;
    }
    
    BOOL prevWasMathsSymbol = NO;
    BOOL prevWasMinusSymbol = NO;
    BOOL currentIsMathsSymbol = NO;
    BOOL currentIsMinusSymbol = NO;
    for (int c = 0; c < [expression length]; c++) {
        char character = [expression characterAtIndex:c];
        
        // Check if current symbol is a minus sign
        if (character == '-') {
            currentIsMinusSymbol = YES;
        }
        
        // Check if current symbol is a maths symbol
        if (character == '+' || character == 'x' || character == 'd' || currentIsMinusSymbol) {
            currentIsMathsSymbol = YES;
        }
        
        // Check each character is either a digit or a maths symbol
        if (!(character >= '0' && character <= '9') && !currentIsMathsSymbol) {
            return NO;
        }
        
        // Check there are no adjacent maths symbols
        if (currentIsMathsSymbol && prevWasMathsSymbol) {
            if (currentIsMinusSymbol && prevWasMinusSymbol) return NO;
            if (!currentIsMinusSymbol) return NO;
        }
        
        prevWasMinusSymbol = currentIsMinusSymbol;
        prevWasMathsSymbol = currentIsMathsSymbol;
        currentIsMinusSymbol = NO;
        currentIsMathsSymbol = NO;
    }
    
    return YES;
}

+ (NSMutableString *) evalBinaryOperator:(NSMutableString *)operator arg1:(NSMutableString *)arg1 arg2:(NSMutableString *)arg2 {
    double arg1Value = [arg1 doubleValue];
    double arg2Value = [arg2 doubleValue];
    
    NSMutableString *result;
    
    if ([operator isEqualToString:@"+"]) {
        result = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%f", arg1Value + arg2Value]];
    } else if ([operator isEqualToString:@"-"]) {
        result = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%f", arg1Value - arg2Value]];
    } else if ([operator isEqualToString:@"x"]) {
        result = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%f", arg1Value * arg2Value]];
    } else {
        if (arg2Value != 0) {
            result = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%f", arg1Value / arg2Value]];
        } else {
            result = [[NSMutableString alloc] initWithString:@"NaN"];
        }
    }
    
    return result;
}

+ (BOOL) checkIf:(NSMutableString *)op1 hasHigherPrecedenceThan:(NSMutableString *)op2 {
    NSDictionary *precedence = @{
                                 @"d" : @2,
                                 @"x" : @1,
                                 @"+" : @0,
                                 @"-" : @0,
                                };
    
    if ([[precedence objectForKey:op1] integerValue] > [[precedence objectForKey:op2] integerValue]) {
        return YES;
    }
    return NO;
}

@end
