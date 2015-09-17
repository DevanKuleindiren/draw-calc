//
//  ViewController.m
//  Draw
//
//  Created by Devan Kuleindiren on 12/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    int timeSinceTouch;
    NSTimer *timeSinceTouchTimer;
    
    BOOL debugMode;
    BOOL evaluatedImage;
}

- (void) initialiseVariables;
- (void) updateMinMaxPoints:(CGPoint)point;
- (CGRect) generateLooseRectWithTightRect:(CGRect) tightRect;
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
    evaluatedImage = NO;
    
    [self initialiseVariables];
    
    // Prediction text field
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

- (void) toggleDebugMode:(UITapGestureRecognizer *)gestureRecogniser {
    debugMode = !debugMode;
    if (!debugMode) [confidenceLabel setText:@""];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (evaluatedImage) {
        self.baseLayer.image = nil;
        evaluatedImage = NO;
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
    
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    NSLog(@"X:%f, Y:%f", currentPoint.x, currentPoint.y);
    
    if ([predictionField isFirstResponder]) {
        [predictionField resignFirstResponder];
    }
}

- (void) updateMinMaxPoints:(CGPoint)point {
    if (point.x < minXPoint) minXPoint = point.x;
    if (point.x > maxXPoint) maxXPoint = point.x;
    if (point.y < minYPoint) minYPoint = point.y;
    if (point.y > maxYPoint) maxYPoint = point.y;
}

// L - lesser, G - greater
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

- (void) classifyWithBound:(CGRect)bound {
    
    NSLog(@"FROM X: %f, FROM Y: %f", bound.origin.x, bound.origin.y);
    Matrix *inputVector = [self.baseLayer.image extractRawImageDataFromX:bound.origin.x fromY:bound.origin.y with28Multiple:(bound.size.width / 28) andInputNodesNo:inputNodesNo];
    
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
            [predictionField setText:[NSString stringWithFormat:@"%@%d", predictionField.text, i]];
        }
    }
}

- (IBAction)evaluate:(id)sender {
    
    // APP IS READY TO CLASSIFY:
    /*
        1. Get an array of vertical separators from some segmentation algorithm
        2. For each pair of separators,
            - Classify the image within the bounds of the separator (treating out of bounds as white)
            - Add the classification result of this image to the end of a string
        3. Parse that string and output the answer
     */
    
    
    CGRect tightRect = CGRectMake(minXPoint, minYPoint, maxXPoint - minXPoint, maxYPoint - minYPoint);
    CGRect looseRect = [self generateLooseRectWithTightRect:tightRect];
    
    if (debugMode) [Debug drawRectBoundsWithLooseRect:looseRect tightRect:tightRect onImageView:self.baseLayer inViewController:self];
    
    [self classifyWithBound:looseRect];
    [self initialiseVariables];
    
    evaluatedImage = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
