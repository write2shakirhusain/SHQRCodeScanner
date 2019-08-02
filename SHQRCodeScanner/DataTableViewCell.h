//
//  DataTableViewCell.h
//  SHQRCodeScanner
//
//  Created by Shakir Husain on 03/08/19.
//  Copyright © 2019 Shakir Husain. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScannedData @"kScannedData"
#define kDataDesc @"kDataDesc"
#define kScannedDateTime @"kScannedDateTime"

NS_ASSUME_NONNULL_BEGIN

@interface DataTableViewCell : UITableViewCell
-(void)updateUIContent:(NSDictionary *)inData;
@end

NS_ASSUME_NONNULL_END
