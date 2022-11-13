//
//  AudioTest.h
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

#import <Foundation/Foundation.h>
#import "Novocaine.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioTest : NSObject

+ (Novocaine *) audioManager;

+(void) try;

@end

NS_ASSUME_NONNULL_END
