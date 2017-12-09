//
//  main.m
//  CAToneFileGenerator
//
//  Created by Andrew Morton on 10/12/17.
//  Copyright © 2017 Andrew Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100
#define DURATION 6.0
#define FILENAME_FORMAT @"%0.3f-square.aif"

int main(int argc, const char * argv[]) {
    
    if (argc < 2){
        printf("Usage: CMToneFileGenerator n\n(where tone is in Hz)*");
        return -1;
    }
    
    double hz = atof(argv[1]);
    
    assert (hz > 0);
    
    NSLog(@"Genrating %f hz tone", hz);
    
    NSString * fileName = [NSString stringWithFormat:FILENAME_FORMAT, hz];
    NSString * filePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:fileName];
    NSURL * fileUrl = [NSURL URLWithString:filePath];
    
    // Prepare the format
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate = SAMPLE_RATE;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mBitsPerChannel = 16;
    asbd.mChannelsPerFrame = 1;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = 2;
    asbd.mBytesPerPacket = 2;
    
    // Setup the file
    AudioFileID audioFile;
    OSStatus audioErr = noErr;
    audioErr = AudioFileCreateWithURL((__bridge CFURLRef)fileUrl, kAudioFileAIFCType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
    
    
    assert(audioErr == noErr);
    
    // Start writing samples
    long maxSampleCount = SAMPLE_RATE * DURATION;
    long sampleCount = 0;
    UInt32 bytesToWrite = 2;
    double wavelengthInSamples = SAMPLE_RATE / hz;
    
    while (sampleCount < maxSampleCount){
        for (int i=0; i<wavelengthInSamples; i++){
            // Square wave
            SInt16 sample;
            if (i<wavelengthInSamples/2){
                sample = CFSwapInt16HostToBig(SHRT_MAX);
            } else {
                sample = CFSwapInt16HostToBig(SHRT_MIN);
            }
            audioErr = AudioFileWriteBytes(audioFile, false, sampleCount*2, &bytesToWrite, &sample);
            assert(audioErr == noErr);
            sampleCount++;
        }
    }
    
    audioErr = AudioFileClose(audioFile);
    assert(audioErr == noErr);
    NSLog(@"Wrote: %ld samples to %@", sampleCount, fileUrl);
    
    return 0;
}
