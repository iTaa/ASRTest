//
//  UserNameViewController.m
//  AVCam
//
//  Created by ChunYing.Jia on 16/6/20.
//
//

#import "UserNameViewController.h"
#import "AAPLCameraViewController.h"
#import "HUD.h"


@interface UserNameViewController () <UITextFieldDelegate, AAPLCameraViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation UserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameTextField.delegate = self;
    self.okButton.enabled = NO;
    [self.okButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length > 5) {
        self.okButton.enabled = YES;
        [self.okButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
    } else {
        self.okButton.enabled = NO;
        [self.okButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    return YES;
}

- (IBAction)okButtonTouch:(id)sender {
    
    
    [self netWorkTest];
    

    
}


-(void)netWorkTest{
    NSMutableDictionary* requestObject = [NSMutableDictionary new];
    [requestObject setObject:@"test" forKey:@"file_name"];
    [requestObject setObject:@"0001"  forKey:@"file_content"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://data.chinapnr.com/asrapi/upload"]];
    request.timeoutInterval = 1;
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
    NSString* requestJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData* httpBody = [requestJSON dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:httpBody];
    [request setValue:[NSString stringWithFormat:@"%u", (unsigned)[httpBody length]] forHTTPHeaderField:@"Content-Length"];
    popWaiting();
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        dismissWaiting();
        NSLog(@"----%@----",response);
        NSLog(@"----%@----",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (![[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"ok"]) {
            NSLog(@"----%@----",connectionError);
            popError(@"网络异常！请确保使用WIFI链接");
        } else {
            AAPLCameraViewController *aac = [self.storyboard instantiateViewControllerWithIdentifier:@"AAPLCameraViewController"];
            aac.userName = self.userNameTextField.text;
            [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:nil]];
            [self.navigationController pushViewController:aac animated:YES];
        }
        
    }];

}


@end
