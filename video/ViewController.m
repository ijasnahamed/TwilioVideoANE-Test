//
//  ViewController.m
//  video
//
//  Created by Nethram LLC on 19/06/18.
//  Copyright © 2018 Nethram LLC. All rights reserved.
//

#import "ViewController.h"
#import <TwilioVideo/TwilioVideo.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *clickBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet TVIVideoView *primaryVIew;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TwilioVideo setLogLevel:TVILogLevelAll];
    
    [self setStatus:@"on did load"];
    
    self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.statusLabel.numberOfLines = 0;
    
    NSUInteger c = [TVICameraCapturer availableSources].count;
    NSUInteger cc = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    
    [self setStatus:[NSString stringWithFormat:@"c: %lu, cc: %lu", (unsigned long) c, (unsigned long) cc]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickHandler:(id)sender {
    [self setStatus:@"clicked"];
}

- (void) setStatus:(NSString *)msg {
    NSLog(@"%@", msg);
    [self.statusLabel setText:msg];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
