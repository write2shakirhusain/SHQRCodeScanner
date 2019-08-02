//
//  SHScannerViewController.h
//  SHQRCodeScanner
//
//  Created by Shakir Husain on 02/08/19.
//  Copyright © 2019 Shakir Husain. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SHScannerDelegate;

@interface SHScannerViewController : UIViewController
@property(nonatomic , weak) id <SHScannerDelegate>delegate;
-(void)startScanning:(BOOL)inStart;
@end

@protocol SHScannerDelegate <NSObject>

@required
-(void)didScanQRCodeInScanner:(SHScannerViewController*)InScanner qrCode:(NSString*)inScannedData andError:(NSError*)inError;

@end

NS_ASSUME_NONNULL_END


