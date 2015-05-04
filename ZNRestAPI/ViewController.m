//
//  ViewController.m
// Copyright (c) 2015 Jonathan Head
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ViewController.h"
#import "ZNRestAPI.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel* responseLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* indicator;

/// This method is called when the user taps the GET button in the success column. It demonstrates a request like one might make for an object, or objects, from the server.
- (IBAction)onSuccessGET:(UIButton*)sender;
/// This method is called when the user taps the POST button in the success column. It demonstrates a request like one may make to log in to an app.
- (IBAction)onSuccessPOST:(UIButton*)sender;
/// This method is called when the user taps the PUT button in the success column.
- (IBAction)onSuccessPUT:(UIButton*)sender;
/// This method is called when the user taps the DELETE button in the success column.
- (IBAction)onSuccessDELETE:(UIButton*)sender;

/// This method is called when the user taps the GET button in the failure column. It fails similar to how a server might respond if it could not find the requested object.
- (IBAction)onFailureGET:(UIButton*)sender;
/// This method is caled when the user taps the POST button in the failure column. It fails similar to how a server might reject invalid login credentials.
- (IBAction)onFailurePOST:(UIButton*)sender;
/// This method is called when the user taps the PUT button in the failure column. It fails similar to how a server might respond if the request contained unexpected data.
- (IBAction)onFailurePUT:(UIButton*)sender;
/// This method is called when the user taps the DELETE button in the failure column. It fails similar to how a server might respond to an API call that did not exist.
- (IBAction)onFailureDELETE:(UIButton*)sender;

@end

@implementation ViewController

#pragma mark - Setup and helper methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupZNRestAPI];
}

- (void)setupZNRestAPI
{
    [ZNRestAPI instance].baseURL = @"http://private-ef994-znrestapi.apiary-mock.com";
    [ZNRestAPI instance].usesAPIVersion = NO;
}

- (void)displayResponse:(id)response error:(NSError*)error
{
    
    [self.indicator stopAnimating];
    self.responseLabel.hidden = NO;
    if(response == nil)
    {
        self.responseLabel.text = @"<No object returned>";
    }
    else
    {
        if(error)
        {
            if(error.userInfo[@"response"])
            { self.responseLabel.text = [NSString stringWithFormat:@"%@\n\n%@", error.localizedDescription, error.userInfo[@"response"]]; }
            else
            { self.responseLabel.text = error.localizedDescription; }
        }
        else
        { self.responseLabel.text = [response description]; }
    }
}

#pragma mark - API call methods
- (void)onSuccessGET:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"success" requestType:ZNHTTPRequestTypeGET params:@{ @"id":@5 } completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onSuccessPOST:(UIButton *)sender
{
    NSDictionary* parameters = @{
        @"username":@"test@test.com",
        @"password":@"miscellaneous"
    };
    
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"success" requestType:ZNHTTPRequestTypePOST params:parameters completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onSuccessPUT:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"success" requestType:ZNHTTPRequestTypePUT params:nil completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onSuccessDELETE:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"success" requestType:ZNHTTPRequestTypeDELETE params:nil completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onFailureGET:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"failure" requestType:ZNHTTPRequestTypeGET params:nil completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onFailurePOST:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"failure" requestType:ZNHTTPRequestTypePOST params:nil completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onFailurePUT:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"failure" requestType:ZNHTTPRequestTypePUT params:nil completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}

- (void)onFailureDELETE:(UIButton *)sender
{
    [self.indicator startAnimating];
    self.responseLabel.hidden = YES;
    [[ZNRestAPI instance] sendRequestToAPI:@"failure" requestType:ZNHTTPRequestTypeDELETE params:nil completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
        if(successful)
        { [self displayResponse:responseObject error:error]; }
        else
        { [self displayResponse:error.localizedDescription error:error]; }
    }];
}


@end
