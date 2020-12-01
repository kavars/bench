//
//  KABattery.h
//  Benchmark
//
//  Created by Kirill Varshamov on 30.11.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

#ifndef KABattery_h
#define KABattery_h

#import <Foundation/Foundation.h>

@interface KABattery : NSObject

@property NSNumber *temperature;
@property NSNumber *currentCapacity;
@property NSNumber *designCapacity;
@property NSNumber *maximumCapacity;

+(KABattery*) updateBatteryStatus;

@end

#endif /* KABattery_h */
