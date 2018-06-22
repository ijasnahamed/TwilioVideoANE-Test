//
//  VideoViewController.h
//  video
//
//  Created by Nethram LLC on 11/03/1940 Saka.
//  Copyright © 1940 Nethram LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwilioVideo/TwilioVideo.h>

@interface VideoViewController : UIViewController <TVIRemoteParticipantDelegate, TVIRoomDelegate, TVIVideoViewDelegate, TVICameraCapturerDelegate>

@end
