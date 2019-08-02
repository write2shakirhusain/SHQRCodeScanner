//
//  DataTableViewCell.m
//  SHQRCodeScanner
//
//  Created by Shakir Husain on 03/08/19.
//  Copyright © 2019 Shakir Husain. All rights reserved.
//

#import "DataTableViewCell.h"


@interface DataTableViewCell(){
 
    __weak IBOutlet UITextView* txtViewDetail;
    __weak IBOutlet UILabel* lblDate;

}
@end

@implementation DataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateUIContent:(NSDictionary *)inData{
   
    lblDate.text = [inData objectForKey: kScannedDateTime];
    txtViewDetail.text = [inData objectForKey: kDataDesc];

}

@end
