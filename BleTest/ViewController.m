//
//  ViewController.m
//  BleTest
//
//  Created by Kefan Jian on 2015/4/2.
//  Copyright (c) 2015年 kefanjian. All rights reserved.
//

#import "ViewController.h"

#define SERVICE_UUID           @"FFE0"
#define CHARACTERISTIC_UUID    @"FFE1"
#define HC_08                  @"F4E8CBC5-7D39-2F6B-6013-5FC60DAD07E6"

@interface ViewController ()
{
    NSMutableArray *peripherals;
    __weak IBOutlet UITableView *theTableView;
}

@end

@implementation ViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [peripherals[indexPath.row] valueForKey:@"name"];
    cell.detailTextLabel.text = [[peripherals[indexPath.row] valueForKey:@"identifier"] valueForKey:@"UUIDString"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_discoveredPeripheral != peripherals[indexPath.row]) {
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            _discoveredPeripheral = peripherals[indexPath.row];
        
            // And connect
            NSLog(@"Connecting to peripheral %@", peripherals[indexPath.row]);
        
            [_centralManager connectPeripheral:peripherals[indexPath.row] options:nil];
                    
        }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    peripherals = [[NSMutableArray alloc] init];
    
    NSLog(@"Joseph Check!!!");
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_centralManager stopScan];
    NSLog(@"Scanning stopped");
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
//        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        [_centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

        NSLog(@"Scanning started");
    }

}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
//    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    if ([peripherals containsObject:peripheral]) {
        return;
    }
    [peripherals addObject:peripheral];
    [theTableView reloadData];
//    
//    if ([peripheral.name isEqualToString:@"HC-08"]) {
//        if (_discoveredPeripheral != peripheral) {
//            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
//            _discoveredPeripheral = peripheral;
//            
//            // And connect
//            NSLog(@"Connecting to peripheral %@", peripheral);
//            
//            [_centralManager connectPeripheral:peripheral options:nil];
//            
//        }
//
//    }
    
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
    [self cleanup];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    
    [_centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    peripheral.delegate = self;
//    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    [peripheral discoverServices:nil];

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
//        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
        
        [peripheral discoverCharacteristics:nil forService:service];

//        NSLog(@"%@",service);

    }
    // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"%@",characteristic);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
            NSLog(@"Reading value for characteristic %@", @"2A37");
            // to know the characteristic value initial state
//            [peripheral readValueForCharacteristic:characteristic];
            NSLog(@"%@",service);
            NSLog(@"%@",service.characteristics);
            
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        NSLog(@"%@",characteristic);
        
        
//        [peripheral readValueForCharacteristic:characteristic];
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
////
//        NSLog(@"%@",service);
//        NSLog(@"%@",characteristic);
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"%@",error.description);
        return;
    }
    
    NSString *value1 = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
//    Byte *testByte = (Byte *)[characteristic.value bytes];
//    
    uint16_t i = 1;
    [characteristic.value getBytes:&i length:sizeof(i)];
    uint8_t a = CFSwapInt16HostToBig(i);
    
    NSLog(@"%i",a);
//
//    NSNumber *num = [NSNumber numberWithUnsignedInt:characteristic.value];
//    NSLog(@"%@",num);


//    NSLog(@"%i",i);

//    NSLog(@"Value %@",characteristic.value);
//    NSLog(@"%@",characteristic);
    
    
//    NSLog(@"Value %@",value1);
    
    // Have we got everything we need?
//    if (value) {
//        imgLampStatus.image = [UIImage imageNamed:@"bulb_5.png"];
//    }
//    else {
//        imgLampStatus.image = [UIImage imageNamed:@"bulb_6.png"];
//    }
    
    
    //        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
    
    //        [_centralManager cancelPeripheralConnection:peripheral];
    //    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
//    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]]) {
//        return;
//    }
    
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        
    } else {
        // Notification has stopped
        [_centralManager cancelPeripheralConnection:peripheral];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    _discoveredPeripheral = nil;
    
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)cleanup {
    
    // See if we are subscribed to a characteristic on the peripheral
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
}

-(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data {
    // Sends data to BLE peripheral to process HID and send EHIF command to PC
    for ( CBService *service in peripheral.services ) {
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    // EVERYTHING IS FOUND, WRITE characteristic!
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    
                    // make sure the received characteristic value and then update status image
                    [peripheral readValueForCharacteristic:characteristic];
                    
                }
            }
        }
    }
}

- (IBAction)switchChanged:(id)sender {
    UISwitch *mySwitch = sender;
    NSLog(@"%d",mySwitch.on);
    
    if (mySwitch.on != false) {
        NSLog(@"switch_On");
        
        NSString *one = @"1";
        [self writeCharacteristic:_discoveredPeripheral sUUID:SERVICE_UUID cUUID:CHARACTERISTIC_UUID data:[one dataUsingEncoding:NSUTF8StringEncoding]];

        
    } else {
        NSLog(@"switch_Off");
        NSString *zero = @"0";
        [self writeCharacteristic:_discoveredPeripheral sUUID:SERVICE_UUID cUUID:CHARACTERISTIC_UUID data:[zero dataUsingEncoding:NSUTF8StringEncoding]];
    }

}

@end
