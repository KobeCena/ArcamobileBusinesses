/*
     File: OverlayViewController.m 
 Abstract: The secondary view controller managing the overlap view to the camera.
  
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "OverlayViewController.h"
#import "Utility.h"
#import "CoreUtility.h"

/************/
//Categorie that perform a scale operation into an UIImage 
@interface UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
- (UIImage*)scaleImageToSize:(CGSize)newSize;
@end

@implementation UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage*)scaleImageToSize:(CGSize)newSize
{
    return [UIImage imageWithImage:self scaledToSize:newSize];
}
@end
/************/


@implementation OverlayViewController

@synthesize delegate, takePictureButton,
            cancelButton,
            tickTimer,
            imagePickerController;


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}

#pragma mark -
#pragma mark OverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:
                                                    [[NSBundle mainBundle] pathForResource:@"Grab"
                                                                                    ofType:@"aif"]],
                                         &tickSound);

        UIImagePickerController *tempController = [[UIImagePickerController alloc] init] ;
        //self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        self.imagePickerController = tempController;
        self.imagePickerController.delegate = self;
        [tempController release];
    }
    return self;
}

- (void)viewDidUnload
{
    self.takePictureButton = nil;
    self.cancelButton = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{	
    [takePictureButton release];
    [cancelButton release];
    
    [imagePickerController release];
    AudioServicesDisposeSystemSoundID(tickSound);

    [tickTimer release];
    
    [super dealloc];
}

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // user wants to use the camera interface
        //
        self.imagePickerController.showsCameraControls = YES;
        self.imagePickerController.allowsEditing=YES;
        /*
        if ([[self.imagePickerController.cameraOverlayView subviews] count] == 0)
        {
            // setup our custom overlay view for the camera
            //
            // ensure that our custom view's frame fits within the parent frame
            CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
            
            CGRect newFrame = CGRectMake(0.0,
                                         0.0,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height);
            
            
            // Uncomment this block os code y=if you intent to show only a custom tabBar for UIImagePickerController
//            CGRect newFrame = CGRectMake(0.0,
//                                         CGRectGetHeight(overlayViewFrame) -
//                                         self.view.frame.size.height - 10.0,
//                                         CGRectGetWidth(overlayViewFrame),
//                                         self.view.frame.size.height + 10.0);
             
            self.view.frame = newFrame;
            [self.view setUserInteractionEnabled:YES];
            [self.imagePickerController.cameraOverlayView addSubview:self.view];
        }
    */
    }
}

// called when the parent application receives a memory warning
- (void)didReceiveMemoryWarning
{
    // we have been warned that memory is getting low, stop all timers
    //
    [super didReceiveMemoryWarning];
    
    // stop all timers
    [self.tickTimer invalidate];
    tickTimer = nil;
}

// update the UI after an image has been chosen or picture taken
//
- (void)finishAndUpdate
{
    [self.delegate didFinishWithCamera];  // tell our delegate we are done with the camera

    // restore the state of our overlay toolbar buttons
    self.cancelButton.enabled = YES;
    self.takePictureButton.enabled = YES;
}


#pragma mark -
#pragma mark Camera Actions

- (IBAction)done:(id)sender
{
    [self finishAndUpdate];
}

- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
    
}


// gets called by our delayed camera shot timer to play a shutter sound
- (void)tickFire:(NSTimer *)timer
{
	AudioServicesPlaySystemSound(tickSound);
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];    

    if (isEmpty(image)) {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    // give the taken picture to our delegate
    if (self.delegate)
        [self.delegate didTakePicture:image];
    
    [self finishAndUpdate];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}



@end

