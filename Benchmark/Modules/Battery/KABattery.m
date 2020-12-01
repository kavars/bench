//
//  KABattery.m
//  Benchmark
//
//  Created by Kirill Varshamov on 30.11.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

#import "KABattery.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/IOKitLib.h>

@implementation KABattery

@synthesize temperature, currentCapacity, designCapacity, maximumCapacity;

-(instancetype) initWithTemperature: (NSNumber *) temperature WithCurrentCapacity: (NSNumber *) currentCapacity WithDesignCapacity: (NSNumber *) designCapacity andWithMaximumCapacity: (NSNumber *) maximumCapacity {
    self = [super init];
    
    if (self) {
        self.temperature = temperature;
        self.currentCapacity = currentCapacity;
        self.designCapacity = designCapacity;
        self.maximumCapacity = maximumCapacity;
    }
    
    return self;
}

+ (KABattery*)updateBatteryStatus {
    
    CFMutableDictionaryRef ioServices, cfBatteryDict = NULL;
    io_registry_entry_t entry = 0;
    ioServices = IOServiceNameMatching("AppleSmartBattery");
    entry = IOServiceGetMatchingService(kIOMasterPortDefault, ioServices);

    IORegistryEntryCreateCFProperties(entry, &cfBatteryDict, NULL, 0);
    NSDictionary *batteryDict = (__bridge NSDictionary *)cfBatteryDict;
    
    // Temperature
    float battTemp = [[batteryDict objectForKey:@"Temperature"] floatValue];
    NSNumber *temp = [[NSNumber alloc] initWithFloat: battTemp / 100];
    
    // Current Capacity
    NSInteger battCurrCap = [[batteryDict objectForKey:@"CurrentCapacity"] integerValue];
    NSNumber *currentCap = [[NSNumber alloc] initWithLong: battCurrCap];
    
    // Design Capacity
    NSInteger battDesCap = [[batteryDict objectForKey:@"DesignCapacity"] integerValue];
    NSNumber *designCapacity = [[NSNumber alloc] initWithLong: battDesCap];
    
    // Full Charge Capacity
    NSInteger battMaxCap = [[batteryDict objectForKey:@"MaxCapacity"] integerValue];
    NSNumber *maximumCapacity = [[NSNumber alloc] initWithLong: battMaxCap];
        
    KABattery *batteryData = [[KABattery alloc] initWithTemperature: temp WithCurrentCapacity: currentCap WithDesignCapacity: designCapacity andWithMaximumCapacity: maximumCapacity];
    
    return batteryData;
}

@end
