//
//  AudioTest.m
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

#import "AudioTest.h"
#import "Novocaine.h"

static Novocaine *audioManager = nil;

@interface AudioTest ()

@end

@implementation AudioTest

+ (Novocaine *) audioManager
{
    @synchronized(self)
    {
        if (audioManager == nil) {
            audioManager = [Novocaine audioManager];
        }
    }
    return audioManager;
}



+(void) try {
    NSLog(@"AudioTest");


    // Basic playthru example
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        NSLog(@"dstest input: %d", numFrames);
//        float volume = 0.5;
//        vDSP_vsmul(data, 1, &volume, data, 1, numFrames*numChannels);
//        wself.ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
    }];

    [self.audioManager setOutputBlock:^(float *newdata, UInt32 numFrames, UInt32 thisNumChannels)
         {
             for (int i = 0; i < numFrames * thisNumChannels; i++) {
                 newdata[i] = (rand() % 100) / 100.0f / 2;
         }
    }];

    [self.audioManager play];
}

@end
