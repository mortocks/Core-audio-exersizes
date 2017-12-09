//
//  main.m
//  CMMetadata
//
//  Created by Andrew Morton on 9/12/17.
//  Copyright © 2017 Andrew Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    
    //NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc < 2) {
        printf("Usage CAMetadata /full/path/to/audiofile\n");
        return -1;
    }
    
    NSString * audioFilePath = [NSString stringWithUTF8String:argv[1]];
    NSURL * audioURL = [NSURL fileURLWithPath:audioFilePath];
    NSLog(@"Path: %@", audioFilePath);
    AudioFileID audioFile;
    OSStatus theErr = noErr;
    
    theErr = AudioFileOpenURL((CFURLRef)CFBridgingRetain(audioURL), kAudioFileReadPermission, 0, &audioFile);
    
    assert (theErr == noErr);
    
    UInt32 dictionarySize = 0;
    
    theErr = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, 0);
    
    assert (theErr == noErr);
    
    CFDictionaryRef dictionary;
    
    theErr = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, &dictionary);
    
    assert (theErr == noErr);
    
    NSLog(@"Dictionary: %@", dictionary);
    
    CFRelease(dictionary);
    
    theErr = AudioFileClose(audioFile);
    
    assert (theErr == noErr);
    
   // [pool drain];
    
    return 0;
}
