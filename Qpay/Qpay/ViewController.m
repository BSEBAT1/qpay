//
//  ViewController.m
//  LinkDemo-ObjC
//
//  Copyright © 2019 Plaid Inc. All rights reserved.
//

// <!-- SMARTDOWN_IMPORT_LINKKIT -->
#import <LinkKit/LinkKit.h>
// <!-- SMARTDOWN_IMPORT_LINKKIT -->

#import "ViewController.h"
#import "CustomerDataObj.h"
#import "Qpay-Swift.h"

// <!-- SMARTDOWN_PROTOCOL -->
@interface ViewController (PLKPlaidLinkViewDelegate) <PLKPlaidLinkViewDelegate>
@end
// <!-- SMARTDOWN_PROTOCOL -->

static const NSString * urlDef = @"http://ebfd01e7.ngrok.io";

@interface ViewController ()
@property IBOutlet UIButton* button;
@property IBOutlet UILabel* label;
@property IBOutlet UIView* buttonContainerView;
@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNotification:)
                                                 name:@"PLDPlaidLinkSetupFinished"
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button.enabled = NO;

    NSBundle* linkKitBundle = [NSBundle bundleForClass:[PLKPlaidLinkViewController class]];
    NSString* linkName      = [linkKitBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    self.label.text         = [NSString stringWithFormat:@"Objective-C — %@ %s+%.0f"
                                 , linkName, LinkKitVersionString, LinkKitVersionNumber];

    UIColor* shadowColor = [UIColor colorWithRed:3/255.0 green:49/255.0 blue:86/255.0 alpha:0.1];
    self.buttonContainerView.layer.shadowColor   = [shadowColor CGColor];
    self.buttonContainerView.layer.shadowOffset  = CGSizeMake(0, -1);
    self.buttonContainerView.layer.shadowRadius  = 2;
    self.buttonContainerView.layer.shadowOpacity = 1;
     self.button.enabled = YES;

}

- (void)didReceiveNotification:(NSNotification*)notification {
    if ([@"PLDPlaidLinkSetupFinished" isEqualToString:notification.name]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:notification.name
                                                      object:self];
        self.button.enabled = YES;
    }
}

- (IBAction)didTapButton:(id)sender {
//#if USE_CUSTOM_CONFIG
    [self presentPlaidLinkWithCustomConfiguration];
//#else
   // [self presentPlaidLinkWithSharedConfiguration];
//#endif
}
-(void) getBalances {
  
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlDef,@"/balance"]];
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
     request.HTTPMethod = @"Get";
     request.timeoutInterval = 5;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         NSLog(@"balance response is : %@, err: %@", response, error);
     NSString * contents =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"The %@",contents);
     }];
     [task resume];
}

- (void)handleSuccessWithToken:(NSString*)publicToken metadata:(NSDictionary<NSString*,id>*)metadata {
   // NSLog(@"I got the token the token is %@",publicToken);
   // NSString* message = [NSString stringWithFormat:@"token: %@\nmetadata: %@", publicToken, metadata];
    //[self presentAlertViewWithTitle:@"Success" message:message];
    NSArray * accounts = (NSArray *) metadata[@"accounts"];
    NSMutableArray *accountObjects = [NSMutableArray new];
    for (int i = 0; i < accounts.count;i++) {
        CustomerDataObj * account = [[CustomerDataObj alloc]init];
         NSDictionary *Item = (NSDictionary *) accounts[i];
         NSString * account_id = Item[@"id"];
         NSString * name = Item[@"name"];
         account.accountId = account_id;
         account.name = name;
         account.publicToken = publicToken;
        [accountObjects addObject:account];
    }
        [self dismissViewControllerAnimated:true completion:^{
            UIViewController * root =  [[UIApplication.sharedApplication keyWindow]rootViewController];
            NSString * storyboardName = @"Plaid";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            CustomerTableViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"showCustomerAccounts"];
            vc.customerData = [accountObjects copy];
            [root presentViewController:vc animated:true completion:^{
                NSLog(@"customer accounts pressed");
            }];
        }];
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlDef,@"/get_access_token"]];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    NSDictionary *firstItem = (NSDictionary *) accounts[0];
//    NSString * account_id = firstItem[@"id"];
//    NSLog(@"withaccount id %@",account_id);
//    NSString *bodyData = [NSString stringWithFormat:@"public_token=%@&account_id=%@",publicToken,account_id];
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = [bodyData dataUsingEncoding:NSUTF8StringEncoding];
//    request.timeoutInterval = 5;
//   NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"resp: %@, err: %@", response, error);
//       [self getAch];
//    }];
//    [task resume];
}

-(void)handleSucessToken:(NSString *)publicToken account:(NSString *)account {
    NSLog(@"I got the token the token is %@",publicToken);
       NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlDef,@"/get_access_token"]];
      NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
       NSString * account_id = account;
       
    NSLog(@"withaccount id %@",account_id);
    
    NSString *bodyData = [NSString stringWithFormat:@"public_token=%@&account_id=%@",publicToken,account_id];
       request.HTTPMethod = @"POST";
       request.HTTPBody = [bodyData dataUsingEncoding:NSUTF8StringEncoding];
       request.timeoutInterval = 5;
      NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           NSLog(@"token response is : %@, err: %@", response, error);
          [self getBalances];
       }];
       [task resume];
}

- (void)handleError:(NSError*)error metadata:(NSDictionary<NSString*,id>*)metadata {
    NSString* message = [NSString stringWithFormat:@"error: %@\nmetadata: %@", [error localizedDescription], metadata];
    [self presentAlertViewWithTitle:@"Failure" message:message];
}

- (void)handleExitWithMetadata:(NSDictionary<NSString*,id>*)metadata {
    NSString* message = [NSString stringWithFormat:@"metadata: %@", metadata];
    [self presentAlertViewWithTitle:@"Exit" message:message];
}

- (void)presentAlertViewWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)getAch {
   
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlDef,@"/auth"]];
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
     request.HTTPMethod = @"Get";
     request.timeoutInterval = 5;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         NSLog(@"balance response is : %@, err: %@", response, error);
     NSString * contents =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"The %@",contents);
     }];
     [task resume];
}

#pragma mark Start Plaid Link with shared configuration from Info.plist
- (void)presentPlaidLinkWithSharedConfiguration {

    // <!-- SMARTDOWN_PRESENT_SHARED -->
    // With shared configuration from Info.plist
    id<PLKPlaidLinkViewDelegate> linkViewDelegate  = self;
    PLKPlaidLinkViewController* linkViewController = [[PLKPlaidLinkViewController alloc] initWithDelegate:linkViewDelegate];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        linkViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:linkViewController animated:YES completion:nil];
    // <!-- SMARTDOWN_PRESENT_SHARED -->
    
}

#pragma mark Start Plaid Link with custom instance configuration
- (void)presentPlaidLinkWithCustomConfiguration {

    // <!-- SMARTDOWN_PRESENT_CUSTOM -->
    // With custom configuration
    PLKConfiguration* linkConfiguration;
    @try {
        linkConfiguration = [[PLKConfiguration alloc] initWithKey:@"948b0f0032f2f5de71ff8632cd5848" env:PLKEnvironmentDevelopment product:PLKProductAuth];
        linkConfiguration.clientName = @"Link Demo";
        id<PLKPlaidLinkViewDelegate> linkViewDelegate  = self;
        PLKPlaidLinkViewController* linkViewController = [[PLKPlaidLinkViewController alloc] initWithConfiguration:linkConfiguration delegate:linkViewDelegate];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            linkViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        [self presentViewController:linkViewController animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"Invalid configuration: %@", exception);
    }
    // <!-- SMARTDOWN_PRESENT_CUSTOM -->

}

#pragma mark Start Plaid Link in update mode
- (void)presentPlaidLinkInUpdateMode {

    // <!-- SMARTDOWN_UPDATE_MODE -->
    id<PLKPlaidLinkViewDelegate> linkViewDelegate  = self;
    PLKPlaidLinkViewController* linkViewController = [[PLKPlaidLinkViewController alloc] initWithPublicToken:@"access-sandbox-3057b26b-94ca-4ecf-bc52-931fd4ac8486" delegate:linkViewDelegate];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        linkViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:linkViewController animated:YES completion:nil];
    // <!-- SMARTDOWN_UPDATE_MODE -->

}

@end


@implementation ViewController (PLKPlaidLinkViewDelegate)

// <!-- SMARTDOWN_DELEGATE_SUCCESS -->
- (void)linkViewController:(PLKPlaidLinkViewController*)linkViewController
 didSucceedWithPublicToken:(NSString*)publicToken
                  metadata:(NSDictionary<NSString*,id>* _Nullable)metadata {
    [self dismissViewControllerAnimated:YES completion:^{
        // Handle success, e.g. by storing publicToken with your service
        NSLog(@"Successfully linked account!\npublicToken: %@\nmetadata: %@", publicToken, metadata);
        [self handleSuccessWithToken:publicToken metadata:metadata];
    }];
}
// <!-- SMARTDOWN_DELEGATE_SUCCESS -->

// <!-- SMARTDOWN_DELEGATE_EXIT -->
- (void)linkViewController:(PLKPlaidLinkViewController*)linkViewController
          didExitWithError:(NSError* _Nullable)error
                  metadata:(NSDictionary<NSString*,id>* _Nullable)metadata {
    [self dismissViewControllerAnimated:YES completion:^{
        if (error) {
            NSLog(@"Failed to link account due to: %@\nmetadata: %@", [error localizedDescription], metadata);
            [self handleError:error metadata:metadata];
        }
        else {
            NSLog(@"Plaid link exited with metadata: %@", metadata);
            [self handleExitWithMetadata:metadata];
        }
    }];
}
// <!-- SMARTDOWN_DELEGATE_EXIT -->

// <!-- SMARTDOWN_DELEGATE_EVENT -->
- (void)linkViewController:(PLKPlaidLinkViewController*)linkViewController
            didHandleEvent:(NSString*)event
                  metadata:(NSDictionary<NSString*,id>* _Nullable)metadata {
    NSLog(@"Link event: %@\nmetadata: %@", event, metadata);
}
// <!-- SMARTDOWN_DELEGATE_EVENT -->

@end

