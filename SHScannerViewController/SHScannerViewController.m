//
//  SHScannerViewController.m
//  SHQRCodeScanner
//
//  Created by Shakir Husain on 02/08/19.
//  Copyright © 2019 Shakir Husain. All rights reserved.
//

#import "SHScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SHScannerViewController ()<AVCaptureMetadataOutputObjectsDelegate> {
    
    __weak IBOutlet UIView *cameraView;
    
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;

}
@property (nonatomic, strong) AVCaptureSession *session;
@end

@implementation SHScannerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self checkCameraPermission];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
    
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self createCaptureVideoPlayer];

}

-(IBAction)clickedOnCloseButton:(id)isSender{
    [self.session stopRunning];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//Setup AV capture session
- (void)setUpCapturingBase {
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    
    [_session startRunning];
    
}

-(void)createCaptureVideoPlayer{
    
    if (_prevLayer == nil) {
        _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _prevLayer.frame = self.view.bounds;
        _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [cameraView.layer addSublayer:_prevLayer];

    }

}

- (void)startScanning:(BOOL)inStart{
    
    if (inStart) {
        [_session startRunning];
    }
    else{
        [_session stopRunning];
    }
}

#pragma mark-
#pragma mark- AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSString *qrCode = nil;
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil) {
            qrCode = [[detectionString componentsSeparatedByString:@","] firstObject] ;
            [_session stopRunning];
            break;
        }
    }
    if (_session.running == NO && qrCode) {
       
        //here get scanning qrcode salt
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(SHScannerDelegate)] && [self.delegate respondsToSelector:@selector(didScanQRCodeInScanner:qrCode:andError:)]) {
            NSError *aError = nil;
            [self.delegate didScanQRCodeInScanner: self qrCode: qrCode andError: aError];
        }
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-
#pragma mark- Camera Permission.

-(void)starScannig{
    [self setUpCapturingBase];
}

- (void)checkCameraPermission{
    
    __weak SHScannerViewController *safeSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
        {
            [self starScannig];
        }
            break;
        case AVAuthorizationStatusRestricted:
        {
            [self showAlertMessage:@"You don't have camera Access. Go to App Settig then enable it."];
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    [safeSelf starScannig];
                }
                else {
                    [safeSelf showAlertMessage:@"You don't have camera Access. Go to App Settig then enable it."];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)showAlertMessage:(NSString *)inMessage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"QrCode Scanning" message:inMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {

                                                         }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
