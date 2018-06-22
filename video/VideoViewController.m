#import "VideoViewController.h"

@interface VideoViewController ()

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *roomName;

#pragma mark Video SDK components

@property (nonatomic, strong) TVICameraCapturer *camera;
@property (nonatomic, strong) TVILocalVideoTrack *localVideoTrack;
@property (nonatomic, strong) TVILocalAudioTrack *localAudioTrack;
@property (nonatomic, strong) TVIRemoteParticipant *remoteParticipant;
@property (nonatomic, weak) TVIVideoView *remoteView;
@property (nonatomic, strong) TVIRoom *room;

#pragma mark UI Element Outlets and handles

@property (nonatomic, weak) IBOutlet UILabel *roomStatus;
@property (weak, nonatomic) IBOutlet TVIVideoView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *disconnectBtn;


@end

@implementation VideoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TwilioVideo setLogLevel:TVILogLevelAll];
    
    self.roomStatus.lineBreakMode = NSLineBreakByWordWrapping;
    self.roomStatus.numberOfLines = 0;
    
    NSString *sim = @"no";
    if([self isSimulator])
        sim = @"yes";
    
    NSUInteger tc = [TVICameraCapturer availableSources].count;
    NSUInteger nc = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    
    NSString *frontAvail = @"no";
    if([TVICameraCapturer isSourceAvailable:TVICameraCaptureSourceFrontCamera])
        frontAvail = @"yes";
    
    NSString *backAvail = @"no";
    if([TVICameraCapturer isSourceAvailable:TVICameraCaptureSourceBackCameraWide])
        backAvail = @"yes";
    
    NSString *backTAvail = @"no";
    if([TVICameraCapturer isSourceAvailable:TVICameraCaptureSourceBackCameraTelephoto])
        backTAvail = @"yes";
    
    [self setStatus:[NSString stringWithFormat:@"twilio camera: %lu, native camera: %lu", (unsigned long) tc, (unsigned long) nc]];
    
    [self startPreview];
}

#pragma mark - Public

- (IBAction)disconnectClicked:(id)sender {
    [self setStatus:@"diconnect btn clicked"];
    
//    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private

- (BOOL)isSimulator {
    #if TARGET_IPHONE_SIMULATOR
        return YES;
    #endif
        return NO;
}

- (void)startPreview {
    
//    self.camera = [[TVICameraCapturer alloc] initWithSource:TVICameraCaptureSourceFrontCamera delegate:self enablePreview:YES];
    self.camera = [[TVICameraCapturer alloc] initWithSource:TVICameraCaptureSourceFrontCamera];
    
//    if(self.camera)
//        [self setStatus:@"camera not empty"];
//    else
//        [self setStatus:@"camera empty"];
    
    self.camera.delegate = self;
//    id del = self.camera.delegate;
    
//    if(del)
//        [self setStatus:@"del not empty"];
//    else
//        [self setStatus:@"del empty"];
    
    self.localVideoTrack = [TVILocalVideoTrack trackWithCapturer:self.camera
                                                     enabled:YES
                                                 constraints:nil
                                                        name:@"Camera"];
    
//    self.localVideoTrack = [TVILocalVideoTrack trackWithCapturer:self.camera];
    
    if (self.localVideoTrack) {
        [self setStatus:@"Failed to add video track"];
    } else {
        // Add renderer to video track for local preview
        [self.localVideoTrack addRenderer:self.previewView];
        
//        [self setStatus:@"Local video track connected"];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera)];
//        [self.previewView addGestureRecognizer:tap];
        
//        [self connect];
    }
}

- (void)flipCamera {
    if (self.camera.source == TVICameraCaptureSourceFrontCamera) {
        [self.camera selectSource:TVICameraCaptureSourceBackCameraWide];
    } else {
        [self.camera selectSource:TVICameraCaptureSourceFrontCamera];
    }
}

- (void)prepareLocalMedia {
    if (!self.localAudioTrack) {
        self.localAudioTrack = [TVILocalAudioTrack trackWithOptions:nil
                                                            enabled:YES
                                                               name:@"Microphone"];
        
        if (!self.localAudioTrack) {
            [self setStatus:@"Failed to add audio track"];
        }
    }
    
    // Create a video track which captures from the camera.
    if (!self.localVideoTrack) {
        [self startPreview];
    }
}

- (void)connect {
    if (!self.accessToken) {
        [self setStatus:@"Please provide a valid token to connect to a room"];
        return;
    } else if (!self.roomName) {
        [self setStatus:@"Please provide a valid room name to connect to a room"];
        return;
    }
    
    [self prepareLocalMedia];
    
    TVIConnectOptions *connectOptions = [TVIConnectOptions optionsWithToken:self.accessToken
                                                                      block:^(TVIConnectOptionsBuilder * _Nonnull builder) {
                                                                          
                                                                          // Use the local media that we prepared earlier.
                                                                          builder.audioTracks = self.localAudioTrack ? @[ self.localAudioTrack ] : @[ ];
                                                                          builder.videoTracks = self.localVideoTrack ? @[ self.localVideoTrack ] : @[ ];
                                                                          
                                                                          // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
                                                                          // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
                                                                          builder.roomName = self.roomName;
                                                                      }];
    
    // Connect to the Room using the options we provided.
    self.room = [TwilioVideo connectWithOptions:connectOptions delegate:self];
    
    [self setStatus:[NSString stringWithFormat:@"Attempting to connect to room %@", self.roomName]];
}

- (void)setupRemoteView {
    TVIVideoView *remoteView = [[TVIVideoView alloc] init];
    
    self.remoteView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view insertSubview:remoteView atIndex:0];
    self.remoteView = remoteView;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:centerX];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:centerY];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:0];
    [self.view addConstraint:width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:0];
    [self.view addConstraint:height];
}

- (void)cleanupRemoteParticipant {
    
}

- (void) setStatus:(NSString *)msg {
    NSLog(@"%@", msg);
    [self.roomStatus setText:msg];
}

#pragma mark - TVIRoomDelegate

- (void)didConnectToRoom:(TVIRoom *)room {
    [self setStatus:[NSString stringWithFormat:@"Connected to room %@ as %@", room.name, room.localParticipant.identity]];
    
    if (room.remoteParticipants.count > 0) {
        self.remoteParticipant = room.remoteParticipants[0];
        self.remoteParticipant.delegate = self;
    }
}

- (void)room:(TVIRoom *)room didDisconnectWithError:(nullable NSError *)error {
    [self setStatus:[NSString stringWithFormat:@"Disconncted from room %@, error = %@", room.name, error]];
    
    [self cleanupRemoteParticipant];
    self.room = nil;
}

- (void)room:(TVIRoom *)room didFailToConnectWithError:(nonnull NSError *)error {
    [self setStatus:[NSString stringWithFormat:@"Failed to connect to room, error = %@", error]];
    
    self.room = nil;
}

- (void)room:(TVIRoom *)room participantDidConnect:(TVIRemoteParticipant *)participant {
    
}

- (void)room:(TVIRoom *)room participantDidDisconnect:(TVIRemoteParticipant *)participant {
    
}

#pragma mark - TVIRemoteParticipantDelegate

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
      publishedVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
    unpublishedVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
      publishedAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
    unpublishedAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    
}

- (void)subscribedToVideoTrack:(TVIRemoteVideoTrack *)videoTrack
                   publication:(TVIRemoteVideoTrackPublication *)publication
                forParticipant:(TVIRemoteParticipant *)participant {
    
}

- (void)unsubscribedFromVideoTrack:(TVIRemoteVideoTrack *)videoTrack
                       publication:(TVIRemoteVideoTrackPublication *)publication
                    forParticipant:(TVIRemoteParticipant *)participant {
    
}

- (void)subscribedToAudioTrack:(TVIRemoteAudioTrack *)audioTrack
                   publication:(TVIRemoteAudioTrackPublication *)publication
                forParticipant:(TVIRemoteParticipant *)participant {
    
}

- (void)unsubscribedFromAudioTrack:(TVIRemoteAudioTrack *)audioTrack
                       publication:(TVIRemoteAudioTrackPublication *)publication
                    forParticipant:(TVIRemoteParticipant *)participant {
    
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
        enabledVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    [self setStatus:[NSString stringWithFormat:@"Participant %@ enabled %@ video track.",
                      participant.identity, publication.trackName]];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
       disabledVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    [self setStatus:[NSString stringWithFormat:@"Participant %@ disabled %@ video track.",
                      participant.identity, publication.trackName]];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
        enabledAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    [self setStatus:[NSString stringWithFormat:@"Participant %@ enabled %@ audio track.",
                      participant.identity, publication.trackName]];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant
       disabledAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    [self setStatus:[NSString stringWithFormat:@"Participant %@ disabled %@ audio track.",
                      participant.identity, publication.trackName]];
}

- (void)failedToSubscribeToAudioTrack:(TVIRemoteAudioTrackPublication *)publication
                                error:(NSError *)error
                       forParticipant:(TVIRemoteParticipant *)participant {
    [self setStatus:[NSString stringWithFormat:@"Participant %@ failed to subscribe to %@ audio track.",
                      participant.identity, publication.trackName]];
}

- (void)failedToSubscribeToVideoTrack:(TVIRemoteVideoTrackPublication *)publication
                                error:(NSError *)error
                       forParticipant:(TVIRemoteParticipant *)participant {
    [self setStatus:[NSString stringWithFormat:@"Participant %@ failed to subscribe to %@ video track.",
                      participant.identity, publication.trackName]];
}

#pragma mark - TVIVideoViewDelegate

- (void)videoView:(TVIVideoView *)view videoDimensionsDidChange:(CMVideoDimensions)dimensions {
    NSLog(@"Dimensions changed to: %d x %d", dimensions.width, dimensions.height);
    [self.view setNeedsLayout];
}

#pragma mark - TVICameraCapturerDelegate

- (void)cameraCapturer:(TVICameraCapturer *)capturer didStartWithSource:(TVICameraCaptureSource)source {
    [self setStatus:@"capturing"];
}

- (void)cameraCapturerWasInterrupted:(TVICameraCapturer *)capturer reason:(AVCaptureSessionInterruptionReason)reason {
    [self setStatus:@"capturing interupted"];
}

- (void)cameraCapturer:(nonnull TVICameraCapturer *)capturer didFailWithError:(NSError *)error {
    [self setStatus:@"capturing failed"];
}

@end
