//
//  HomeViewController.m
//  SHQRCodeScanner
//
//  Created by Shakir Husain on 02/08/19.
//  Copyright © 2019 Shakir Husain. All rights reserved.
//

#import "HomeViewController.h"
#import "SHScannerViewController.h"
#import "DataTableViewCell.h"


@interface HomeViewController ()<SHScannerDelegate,UITableViewDataSource,UITableViewDelegate>{
    __weak IBOutlet UITableView *tblView;
}

@property(nonatomic,strong) SHScannerViewController *scannerViewCon;
@property(nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadDataSource];
}

-(void)initiallySetup{
    
    [tblView registerNib:[UINib nibWithNibName:@"DataTableViewCell" bundle:nil] forCellReuseIdentifier:@"DataTableViewCell"];
}

//Lazy Instantiation.
- (NSMutableArray *)dataSource{
    
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

// create and Opening Scanner.
-(void)openScener{
  
    self.scannerViewCon = [[SHScannerViewController alloc] initWithNibName:@"SHScannerViewController" bundle: nil];
    self.scannerViewCon.delegate = self;
    
    [self presentViewController: self.scannerViewCon animated:YES completion:^{
    }];

}

//Start Scnning.
-(IBAction)clickedOnStartScan:(id)isSender{
    [self openScener];
}

//Load Old Data if Exist.
-(void)loadDataSource{
   
    NSMutableArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:kScannedData];
    if (arr) {
        [self.dataSource addObjectsFromArray: arr];
    }
    [tblView reloadData];
}

//Update datasource with new scnned data.
-(void)updateDataSource:(id )inScannedData{
    
    NSMutableDictionary *aDataDict =[NSMutableDictionary dictionary];
    [aDataDict setObject:inScannedData forKey:kDataDesc];
    [aDataDict setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:kScannedDateTime];

    [self.dataSource addObject: aDataDict];
    [[NSUserDefaults standardUserDefaults] setObject: self.dataSource forKey:kScannedData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tblView reloadData];
}


//Show Scanned Data mean while scanning.
- (void)showAlertMessage:(NSString *)inMessage {
    __weak HomeViewController *safeSelf = self;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Scnned QrCode" message:inMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [safeSelf.scannerViewCon startScanning: YES];
                                                     }];
    [alertController addAction:okAction];
    
    [self.presentedViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark-
#pragma mark- SCanner Delegate

- (void)didScanQRCodeInScanner:(SHScannerViewController *)InScanner qrCode:(NSString *)inScannedData andError:(NSError *)inError{
    
    if (inError == nil) {
        [self updateDataSource: inScannedData];
        [self showAlertMessage: inScannedData];
    }
}

#pragma mark-
#pragma mark- Table DataSopurce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    DataTableViewCell *aCell = [tblView dequeueReusableCellWithIdentifier: @"DataTableViewCell"];
    [aCell updateUIContent: self.dataSource[indexPath.row]];
    return aCell;
}

#pragma mark-
#pragma mark- TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

@end
