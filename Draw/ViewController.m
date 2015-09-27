//
//  ViewController.m
//  Draw
//
//  Created by Devan Kuleindiren on 12/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    // The NN to use
    FNN3Layer *neuralNetwork;
    
    // Track whether debug mode is on
    BOOL debugMode;
    
    // Track whether the current image has been evaluated
    BOOL evaluatedImage;
    
    // Overall bound on drawn expression
    int overallMinX;
    int overallMinY;
    int overallMaxX;
    int overallMaxY;
}

- (CGRect) generateLooseRectWithTightRect:(CGRect) tightRect;

@end

const int inputNodesNo = 785;
const int hiddenNeuronNo1 = 28;
const int hiddenNeuronNo2 = 20;
const int outputNeuronNo = 14;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialise variables
    brush = 12.0;
    debugMode = NO;
    evaluatedImage = NO;
    [self initialiseOverallBoundVariables];
    neuralNetwork = [[FNN3Layer alloc] initWithInputNodes:inputNodesNo hiddenNeurons1:hiddenNeuronNo1 hiddenNeurons2:hiddenNeuronNo2 outputNeurons:outputNeuronNo];
    
    // Prediction text field
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    predictionField.leftView = paddingView;
    predictionField.leftViewMode = UITextFieldViewModeAlways;
    
    // Gesture recogniser
    UILongPressGestureRecognizer *longPressRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDebugMode:)];
    
    [longPressRecogniser setNumberOfTouchesRequired:1];
    [longPressRecogniser setMinimumPressDuration:2.0];
    [self.view addGestureRecognizer:longPressRecogniser];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) toggleDebugMode:(UITapGestureRecognizer *)gestureRecogniser {
    if (gestureRecogniser.state == UIGestureRecognizerStateBegan) {
        UIAlertView *debugAlert = [[UIAlertView alloc] initWithTitle:@"Toggle Debug Mode?" message:nil delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yeah!", nil];
        [debugAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Toggle debug cancelled
    }
    else {
        // Toggle debug confirmed
        debugMode = !debugMode;
        if (!debugMode) [confidenceLabel setText:@""];
    }
}

- (void) initialiseOverallBoundVariables {
    overallMinX = INT32_MAX;
    overallMinY = INT32_MAX;
    overallMaxX = 0;
    overallMaxY = 0;
}

- (void) updateOverallBoundVariablesWithPointX:(int)x Y:(int)y {
    if (x < overallMinX) overallMinX = x;
    if (y < overallMinY) overallMinY = y;
    if (x > overallMaxX) overallMaxX = x;
    if (y > overallMaxY) overallMaxY = y;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (evaluatedImage) {
        self.baseLayer.image = nil;
        predictionField.text = @"";
        [self initialiseOverallBoundVariables];
        evaluatedImage = NO;
    }
    
    mouseSwiped = NO;
    // Reference any one of the touch starting points (there may be multiple, so only select one)
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
    
    if (![predictionField isFirstResponder]) {
        // Update overall bound on drawn expression
        [self updateOverallBoundVariablesWithPointX:lastPoint.x Y:lastPoint.y];
        
        // Start line drawing from current point
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
    
    // Update overall bound on drawn expression
    [self updateOverallBoundVariablesWithPointX:currentPoint.x Y:currentPoint.y];
    
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
    
    if ([predictionField isFirstResponder]) {
        [predictionField resignFirstResponder];
    } else {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];
        
        // Update overall bound on drawn expression
        [self updateOverallBoundVariablesWithPointX:currentPoint.x Y:currentPoint.y];
    }
}

- (IBAction)evaluate:(id)sender {
    
    /* PLAN:
        - Apply connected-component labelling algorithm to rawData, storing the labels in the RGB slots of the pixel values.
        - As this is applied, the number of pixels, mean x value and mean y value are kept track of for each label
        - Based on these counts, smaller (below a certain threshold) components are merged with the next-nearest component (based on mean x and y values).
        - TO DO IN FUTURE: Also, separate incorrectly joined components.
        - The merging is achieved using binary digits. E.g. if we want to merge components 1 and 3, then we pass 00000101 = 5 to the classifier method. The classifier method will then only regard a pixel if it has a label for which (5 >> (label - 1)) & 1 is 1.
        - The classification method will then calculate the tight and loose rect, compress it to 28x28 and then feed it into the NN
        - Construct a string from the outputs, and pass it into the parser
        - Display the result in the textbox.
     */
    if (self.baseLayer.image == nil) return;
    
    unsigned char *rawData = [self.baseLayer.image extractRawImageData];
    
    unsigned long int *labelEncodings = [self.baseLayer.image labelConnectedComponentsIn:rawData];
    
    for (int i = 1; i < labelEncodings[0] + 1; i++) {
        NSLog(@"LABEL ENCODING %d: %lu", i, labelEncodings[i]);
    }
    
    NSMutableString *output = [[NSMutableString alloc] initWithString:@""];
    
    // Classify the components with a significant number of pixels
    for (int i = 1; i < labelEncodings[0] + 1; i++) {
        [output appendString:[self classifyWithRawData:rawData andLabelEncoding:labelEncodings[i]]];
    }

    [predictionField setText:[NSString stringWithFormat:@"%@%@", predictionField.text, [ExpressionParser parseExpressionWithNoBrackets:output]]];
    
    free(labelEncodings);
    free(rawData);
    
    evaluatedImage = YES;
}

- (NSString *) classifyWithRawData:(unsigned char *)rawData andLabelEncoding:(unsigned long int)labelEncoding {
    
    // Find the bounds of the drawn image, minX, minY, maxX and maxY
    int minX = INT32_MAX;
    int minY = INT32_MAX;
    int maxX = 0;
    int maxY = 0;
    
    // Find minX
    BOOL found = NO;
    for (int x = overallMinX; x < self.baseLayer.image.size.width; x++) {
        for (int y = overallMinY; y < self.baseLayer.image.size.height; y++) {
            if ([self getPixelFromRawData:rawData x:x y:y withLabelEncoding:labelEncoding] > 0) {
                minX = x;
                found = YES;
                break;
            }
        }
        if (found) break;
    }
    
    // Find minY
    found = NO;
    for (int y = overallMinY; y < self.baseLayer.image.size.height; y++) {
        for (int x = overallMinX; x < self.baseLayer.image.size.width; x++) {
            if ([self getPixelFromRawData:rawData x:x y:y withLabelEncoding:labelEncoding] > 0) {
                minY = y;
                found = YES;
                break;
            }
        }
        if (found) break;
    }
    
    // Find maxX
    found = NO;
    for (int x = overallMaxX; x >=0; x--) {
        for (int y = overallMinY; y < self.baseLayer.image.size.height; y++) {
            if ([self getPixelFromRawData:rawData x:x y:y withLabelEncoding:labelEncoding] > 0) {
                maxX = x;
                found = YES;
                break;
            }
        }
        if (found) break;
    }
    
    // Find maxY
    found = NO;
    for (int y = overallMaxY; y >= 0; y--) {
        for (int x = overallMinX; x < self.baseLayer.image.size.width; x++) {
            if ([self getPixelFromRawData:rawData x:x y:y withLabelEncoding:labelEncoding] > 0) {
                maxY = y;
                found = YES;
                break;
            }
        }
        if (found) break;
    }
    
    // Generate the tight rectangle around the image
    CGRect tightRect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    // From this, generate a looser bound, which has dimensions which are a multiple of 28 (makes compression easy)
    CGRect looseRect = [self generateLooseRectWithTightRect:tightRect];
    
    // Display these bounds if debugging
    if (debugMode) [Debug drawRectBoundsWithLooseRect:looseRect tightRect:tightRect onImageView:self.baseLayer inViewController:self];
    
    // Get the input vector from the data within the loose bound
    Matrix *inputVector = [self.baseLayer.image extractInputVectorFromRawData:rawData fromX:looseRect.origin.x fromY:looseRect.origin.y with28Multiple:(looseRect.size.width / 28) inputNodesNo:inputNodesNo labelEncoding:labelEncoding];
    
    [Debug printMatrixIntValueFlat:inputVector];
    
    // Feed the data through the NN
    Matrix *outputVector = [neuralNetwork useNetWithInputs:inputVector andBeta:1.0];
    
    // Show the actual score given by the NN for the output
    if (debugMode) {
        double max = [[outputVector row:0 col:0] doubleValue];
        for (int i = 1; i < 10; i++) {
            if ([[outputVector row:0 col:i] doubleValue] > max) {
                max = [[outputVector row:0 col:i] doubleValue];
            }
        }
        [confidenceLabel setText:[NSString stringWithFormat:@"Confidence: %f", max]];
    }
    
    // Set the highest output to 1, the rest to 0
    [outputVector rectifyActivations];
    
    // Display this output
    NSString *output;
    BOOL outputFound = NO;
    for (int i = 0; i < 10; i++) {
        if ([[outputVector row:0 col:i] doubleValue] == 1.0) {
            output = [NSString stringWithFormat:@"%d", i];
            outputFound = YES;
        }
    }
    if (!outputFound) {
        if ([[outputVector row:0 col:10] doubleValue] == 1.0) {
            output = @"+";
        } else if ([[outputVector row:0 col:11] doubleValue] == 1.0) {
            output = @"-";
        } else if ([[outputVector row:0 col:12] doubleValue] == 1.0) {
            output = @"x";
        } else {
            output = @"d";
        }
    }
    
    return output;
}

- (int) getPixelFromRawData:(unsigned char *)rawData x:(int)x y:(int)y withLabelEncoding:(unsigned long int)labelEncoding {
    if (x >= 0 && x < self.baseLayer.image.size.width && y >= 0 && y < self.baseLayer.image.size.height) {
        unsigned char label = rawData[(y * 4 * (int) self.baseLayer.image.size.width) + (x * 4)];
        if ((labelEncoding >> label) & 1) {
            return rawData[((y * 4 * (int) self.baseLayer.image.size.width) + (x * 4)) + 3];
        }
    }
    return 0;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
