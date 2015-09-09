//
//  ViewController.h
//  Draw
//
//  Created by Devan Kuleindiren on 12/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Debug.h"
#import "DeepNet.h"
#import "UIImage+UIImage_PixelInteraction.h"

@interface ViewController : UIViewController {
    
    // Previous point to draw line from
    CGPoint lastPoint;
    
    // Square heuristics
    int maxXPoint;
    int minXPoint;
    int maxYPoint;
    int minYPoint;
    
    // Line properties
    CGFloat brush;
    
    BOOL mouseSwiped;
    
    IBOutlet UITextField *predictionField;
    IBOutlet UILabel *confidenceLabel;
}

@property (strong, nonatomic) IBOutlet UIImageView *baseLayer;

@end

