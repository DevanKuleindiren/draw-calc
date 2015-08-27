//
//  ViewController.m
//  Draw
//
//  Created by Devan Kuleindiren on 12/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "ViewController.h"
#import "DeepNet.h"

@interface ViewController () {
    
    int timeSinceTouch;
    NSTimer *timeSinceTouchTimer;
    
    BOOL debugMode;
}

- (void) initialiseVariables;
- (void) updateMinMaxPoints:(CGPoint)point;
- (CGRect) generateLooseRectWithTightRect:(CGRect) tightRect;
- (void) drawRectBoundsWithLooseRect:(CGRect)looseRect tightRect:(CGRect)tightRect;
- (void) classifyWithBound:(CGRect)bound;


@end


const int inputNodesNo = 785;
const int hiddenNeuronNo = 15;
const int outputNeuronNo = 10;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialise variables
    brush = 12.0;
    debugMode = NO;
    
    [self initialiseVariables];
    
    // Prediction field
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    predictionField.leftView = paddingView;
    predictionField.leftViewMode = UITextFieldViewModeAlways;
    
    // Gesture recogniser
    UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDebugMode:)];
    
    [tapRecogniser setNumberOfTouchesRequired:1];
    [tapRecogniser setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:tapRecogniser];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) initialiseVariables {
    timeSinceTouch = 0;
    minXPoint = 10000;
    maxXPoint = 0;
    minYPoint = 10000;
    maxYPoint = 0;
}

- (void) updateTimeSinceTouch {
    timeSinceTouch++;
    NSLog(@"WORKS");
    
    if (timeSinceTouch > 6) {
        [timeSinceTouchTimer invalidate];
        
        CGRect tightRect = CGRectMake(minXPoint, minYPoint, maxXPoint - minXPoint, maxYPoint - minYPoint);
        CGRect looseRect = [self generateLooseRectWithTightRect:tightRect];
        
        if (debugMode) [self drawRectBoundsWithLooseRect:looseRect tightRect:tightRect];
        
        [self classifyWithBound:looseRect];
        [self initialiseVariables];
    }
}

- (void) toggleDebugMode:(UITapGestureRecognizer *)gestureRecogniser {
    debugMode = !debugMode;
    if (!debugMode) [confidenceLabel setText:@""];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    timeSinceTouch = 0;
    
    if (![timeSinceTouchTimer isValid]) {
        self.baseLayer.image = nil;
    }
    
    mouseSwiped = NO;
    // Reference any one of the touch starting points (there may be multiple, so only select one)
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
    
    if (![predictionField isFirstResponder]) {
        [self updateMinMaxPoints:lastPoint];
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.baseLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.baseLayer.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    [self updateMinMaxPoints:currentPoint];
    
    // This sets up an image context
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.baseLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // Then draws a line from the last recorded to the current one
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    // Some characterisation of the line
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    // This adds the drawn line to the image of the temporary layer
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.baseLayer.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.baseLayer setAlpha:1.0];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Initialise timer
    if ([predictionField isFirstResponder]) {
        [predictionField resignFirstResponder];
        if ([timeSinceTouchTimer isValid]) [timeSinceTouchTimer invalidate];
    } else {
        if ([timeSinceTouchTimer isValid]) {
            timeSinceTouch = 0;
        } else {
            timeSinceTouchTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTimeSinceTouch) userInfo:nil repeats:YES];
        }
    }
}

- (void) updateMinMaxPoints:(CGPoint)point {
    if (point.x < minXPoint) minXPoint = point.x;
    if (point.x > maxXPoint) maxXPoint = point.x;
    if (point.y < minYPoint) minYPoint = point.y;
    if (point.y > maxYPoint) maxYPoint = point.y;
}

- (CGRect) generateSquareWithMinL:(int)minL maxL:(int)maxL minG:(int)minG maxG:(int)maxG isYG:(BOOL)isYG {
    minL -= 35;
    minG -= 35;
    maxL += 35;
    maxG += 35;
    
    int gDiff = (maxG - minG);
    int lDiff = (maxL - minL);
    
    if (gDiff % 28 != 0) {
        int nextHighest = ((gDiff / 28) + 1) * 28;
        int toChange = nextHighest - gDiff;
            
        minG -= (toChange / 2);
        maxG += (toChange / 2);
        if (toChange % 2 != 0) minG -= 1;
        gDiff = maxG - minG;
    }
    minL -= ((gDiff - lDiff) / 2);
    maxL += ((gDiff - lDiff) / 2);
    if ((gDiff - lDiff) % 2 != 0) minL -= 1;
    
    if (isYG) return CGRectMake(minL + 1, minG + 1, maxL - minL, maxG - minG);
    else return CGRectMake(minG + 1, minL + 1, maxG - minG, maxL - minL);
}

- (Matrix *) extractRawImageData:(UIImage *)image fromX:(int)x fromY:(int)y with28Multiple:(int)multiple {
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    Matrix *inputVector = [[Matrix alloc] initWithRows:1 cols:inputNodesNo];
    Matrix *test = [[Matrix alloc] initWithRows:28 cols:28];
    
    for (int row = 0; row < 28; row++) {
        for (int col = 0; col < 28; col++) {
            double sum = 0;
            
            for (int subRow = 0; subRow < multiple; subRow++) {
                NSUInteger byteIndex = (bytesPerRow * (y + (row * multiple) + subRow)) + ((x + (col * multiple)) * bytesPerPixel);
                for (int subCol = 0; subCol < multiple; subCol++) {
                    sum += rawData[byteIndex + 3];
                    byteIndex += bytesPerPixel;
                }
            }
            
            sum = floor(sum / (multiple * multiple));
            
            [test insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:sum]];
            [inputVector insertObjectAtRow:0 col:((row * 28) + col) obj:[NSNumber numberWithDouble:sum]];
        }
    }
    
    [inputVector insertObjectAtRow:0 col:(inputNodesNo - 1) obj:[NSNumber numberWithDouble:0]];
    [inputVector insertObjectAtRow:0 col:0 obj:[NSNumber numberWithDouble:-1]];
    free(rawData);
    
    return inputVector;
}

- (void) displayInput:(NSArray *)input {
    NSMutableString *row = [[NSMutableString alloc] initWithString:@""];
    for (NSArray *a in input) {
        for (NSNumber *n in a) {
            [row appendString:[NSString stringWithFormat:@"%d", [n intValue]]];
        }
        NSLog(row, nil);
        [row setString:@""];
    }
}

- (CGRect) generateLooseRectWithTightRect:(CGRect)tightRect {
    if (tightRect.size.height > tightRect.size.width) {
        return [self generateSquareWithMinL:tightRect.origin.x
                                       maxL:tightRect.origin.x + tightRect.size.width
                                       minG:tightRect.origin.y
                                       maxG:tightRect.origin.y + tightRect.size.height isYG:YES];
    } else {
        return [self generateSquareWithMinL:tightRect.origin.y
                                       maxL:tightRect.origin.y + tightRect.size.height
                                       minG:tightRect.origin.x
                                       maxG:tightRect.origin.x + tightRect.size.width isYG:NO];
    }
}

- (void) drawRectBoundsWithLooseRect:(CGRect)looseRect tightRect:(CGRect)tightRect {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.baseLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    
    // Add tight rectangular bound
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 10.0, 0, 1.0);
    CGContextAddRect(UIGraphicsGetCurrentContext(), tightRect);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    // Add loose 28 multiple square bound
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 255, 0, 1.0);
    CGContextAddRect(UIGraphicsGetCurrentContext(), looseRect);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.baseLayer.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void) classifyWithBound:(CGRect)bound {
    Matrix *inputVector = [self extractRawImageData:self.baseLayer.image fromX:bound.origin.x fromY:bound.origin.y with28Multiple:(bound.size.width / 28)];
    
    DeepNet *neuralNetwork = [[DeepNet alloc] initWithInputNodes:inputNodesNo hiddenNeurons:hiddenNeuronNo outputNeurons:outputNeuronNo];
    Matrix *outputVector = [neuralNetwork useNetWithInputs:inputVector andBeta:1.0];
    
    if (debugMode) {
        double max = [[outputVector row:0 col:0] doubleValue];
        for (int i = 1; i < 10; i++) {
            if ([[outputVector row:0 col:i] doubleValue] > max) {
                max = [[outputVector row:0 col:i] doubleValue];
            }
        }
        [confidenceLabel setText:[NSString stringWithFormat:@"Confidence: %f", max]];
    }
    
    [outputVector rectifyActivations];
    
    for (int i = 0; i < 10; i++) {
        if ([[outputVector row:0 col:i] doubleValue] == 1.0) {
            NSLog(@"PREDICTION: %d", i);
            [predictionField setText:[NSString stringWithFormat:@"%@%d", predictionField.text, i]];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
