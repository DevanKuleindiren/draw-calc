//
//  ViewController.h
//  Draw
//
//  Created by Devan Kuleindiren on 12/06/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Debug.h"
#import "FNN3Layer.h"
#import "UIImage+UIImage_PixelInteraction.h"
#import "ExpressionParser.h"

@interface ViewController : UIViewController {
    
    // Previous point to draw line from
    CGPoint lastPoint;
    
    // Line properties
    CGFloat brush;
    
    BOOL mouseSwiped;
    
    IBOutlet UITextField *predictionField;
    IBOutlet UIButton *evaluateButton;
    IBOutlet UILabel *confidenceLabel;
}

@property (strong, nonatomic) IBOutlet UIImageView *baseLayer;

- (IBAction)evaluate:(id)sender;

@end

