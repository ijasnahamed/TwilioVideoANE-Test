#import "FlashRuntimeExtensions.h"
#import "VideoViewController.h"
#import "ViewController.h"

FREObject startVideo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    /*
     Code to start video from xib file
     */
    UIApplication *app = [UIApplication sharedApplication];
    VideoViewController *myViewController;

    NSBundle * mainBundle = [NSBundle mainBundle];
    NSString * pathToMyBundle = [mainBundle pathForResource:@"View" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:pathToMyBundle];
    myViewController = [[VideoViewController alloc] initWithNibName:nil bundle:bundle];
    
    [app.keyWindow.rootViewController presentViewController:myViewController animated:false completion:nil];
    
    /*
     Code to start video from storyboard
     */
    
//    UIApplication *app = [UIApplication sharedApplication];
//    ViewController *myViewController;
//
//    NSBundle * mainBundle = [NSBundle mainBundle];
//    NSString * pathToMyBundle = [mainBundle pathForResource:@"View" ofType:@"bundle"];
//    NSBundle *bundle = [NSBundle bundleWithPath:pathToMyBundle];
//
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VideoStoryBoard" bundle:bundle];
//    myViewController = (ViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//
//    [app.keyWindow.rootViewController presentViewController:myViewController animated:false completion:nil];
    
    return NULL;
}

void VideoExtContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    *numFunctionsToTest = 1;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "start";
    func[0].functionData = NULL;
    func[0].function = &startVideo;
    
    *functionsToSet = func;
}

void VideoExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &VideoExtContextInitializer;
}
