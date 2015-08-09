//
//  ViewController.m
//  KonashiPIO
//
//  Created by 浜谷 光吉 on 2015/04/19.
//  Copyright (c) 2015年 LuckyLightning. All rights reserved.
//

#import "ViewController.h"
#import "Konashi.h"

@interface ViewController ()

@end

@implementation ViewController{
    //Konashi connection
    NSString *konashiConnectLabelText;
    IBOutlet UILabel *konashiConnectLabel;
    
    //バッテリーの値
    NSString *batteryLabelText;
    IBOutlet UILabel *batteryLabel;
    IBOutlet UIProgressView *batteryProgView;
    
    //RSSIの値
    NSString *signalLabelText;
    IBOutlet UILabel *signalLabel;
    IBOutlet UIProgressView *signalProgView;
    
    //AIO 0
    NSString *aio0LabelText;
    IBOutlet UILabel *aio0Label;
    IBOutlet UIProgressView *aio0ProgView;
    
    //AIO 1
    NSString *aio1LabelText;
    IBOutlet UILabel *aio1Label;
    IBOutlet UIProgressView *aio1ProgView;
    
    //AIO 2
    NSString *aio2LabelText;
    IBOutlet UILabel *aio2Label;
    IBOutlet UIProgressView *aio2ProgView;
    
    //PIO 0 (SW 1)
    NSString *pio0LabelText;
    IBOutlet UILabel *pio0Label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [Konashi initialize];
    [Konashi addObserver:self
                selector:@selector(ready)
                    name:KONASHI_EVENT_READY];
    [Konashi addObserver:self
                selector:@selector(disconnected)
                    name:KONASHI_EVENT_DISCONNECTED];
    [Konashi addObserver:self
                selector:@selector(updateBattery)
                    name:KONASHI_EVENT_UPDATE_BATTERY_LEVEL];
    [Konashi addObserver:self
                selector:@selector(updateRSSI)
                    name:KONASHI_EVENT_UPDATE_SIGNAL_STRENGTH];
    [Konashi addObserver:self
                selector:@selector(readAio0)
                    name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO0];
    [Konashi addObserver:self
                selector:@selector(readAio1)
                    name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO1];
    [Konashi addObserver:self
                selector:@selector(readAio2)
                    name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO2];
    [Konashi addObserver:self
                selector:@selector(showPIO0State)
                    name:KONASHI_EVENT_UPDATE_PIO_INPUT];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findPushed:(id)sender{
    [Konashi find];
}

- (IBAction)resetPushed:(id)sender{
    [Konashi reset];
}

- (void)ready {
    NSLog(@"CONNECTED");
    //Konashiの名前を表示
    konashiConnectLabelText = [Konashi peripheralName];
    [konashiConnectLabel setText:konashiConnectLabelText];
    [konashiConnectLabel setTextColor:[UIColor colorWithRed:0.235 green:0.702 blue:0.443 alpha:1.0]];
    
    //バッテリー
    NSTimer *tmBat = [NSTimer
                      scheduledTimerWithTimeInterval:60.0f
                      target:self
                      selector:@selector(onBatteryTimer:)
                      userInfo:nil
                      repeats:YES];
    [tmBat fire];
    
    //RSSI
    NSTimer *tmRSSI = [NSTimer
                       scheduledTimerWithTimeInterval:1.0f
                       target:self
                       selector:@selector(onRSSITimer:)
                       userInfo:nil
                       repeats:YES];
    [tmRSSI fire];
    
    //PIO
    //[Konashi pinMode:PIO0 mode:OUTPUT];
    [Konashi pinMode:PIO1 mode:OUTPUT];
    [Konashi pinMode:PIO2 mode:OUTPUT];
    [Konashi pinMode:PIO3 mode:OUTPUT];
    [Konashi pinMode:PIO4 mode:OUTPUT];
    [Konashi pinMode:PIO5 mode:OUTPUT];
    
    //AIO 0
    NSTimer *tmAio0 = [NSTimer
                       scheduledTimerWithTimeInterval:0.4f
                       target:self
                       selector:@selector(onReadAio0Timer:)
                       userInfo:nil
                       repeats:YES];
    [tmAio0 fire];
    //AIO 1
    NSTimer *tmAio1 = [NSTimer
                       scheduledTimerWithTimeInterval:0.4f
                       target:self
                       selector:@selector(onReadAio1Timer:)
                       userInfo:nil
                       repeats:YES];
    [tmAio1 fire];
    //AIO 2
    NSTimer *tmAio2 = [NSTimer
                       scheduledTimerWithTimeInterval:0.4f
                       target:self
                       selector:@selector(onReadAio2Timer:)
                       userInfo:nil
                       repeats:YES];
    [tmAio2 fire];
}

- (void)disconnected{
    NSLog(@"DISCONNECTED");
    konashiConnectLabelText = [NSString stringWithFormat:@"Disconnected"];
    [konashiConnectLabel setText:konashiConnectLabelText];
    [konashiConnectLabel setTextColor:[UIColor redColor]];
}

- (void) onBatteryTimer:(NSTimer*)timer{
    [Konashi batteryLevelReadRequest];
}
- (void) updateBattery{
    int batteryVal = [Konashi batteryLevelRead];
    batteryLabelText = [NSString stringWithFormat:@"%d", batteryVal];
    [batteryLabel setText:batteryLabelText];
    batteryProgView.progress = (float)batteryVal/100;
    //NSLog(@"readBattery: %d", batteryVal);
}

- (void) onRSSITimer:(NSTimer*)timer{
    [Konashi signalStrengthReadRequest];
}
- (void) updateRSSI{
    int signalStrength = [Konashi signalStrengthRead];
    signalLabelText = [NSString stringWithFormat:@"%d", signalStrength];
    [signalLabel setText:signalLabelText];
    signalProgView.progress = (float)(100+signalStrength)/70;
}


- (void)showPIO0State{
    if ([Konashi digitalRead:S1] == HIGH) {
        pio0LabelText = [NSString stringWithFormat:@"ON"];
    } else {
        pio0LabelText = [NSString stringWithFormat:@"OFF"];
    }
    [pio0Label setText:pio0LabelText];
}
- (IBAction)PIO1Pushed:(UISwitch *)sender{
    if(sender.on == YES){
        [Konashi digitalWrite:PIO1 value:HIGH];
    } else {
        [Konashi digitalWrite:PIO1 value:LOW];
    }
}
- (IBAction)PIO2Pushed:(UISwitch *)sender{
    if(sender.on == YES){
        [Konashi digitalWrite:PIO2 value:HIGH];
    } else {
        [Konashi digitalWrite:PIO2 value:LOW];
    }
}
- (IBAction)PIO3Pushed:(UISwitch *)sender{
    if(sender.on == YES){
        [Konashi digitalWrite:PIO3 value:HIGH];
    } else {
        [Konashi digitalWrite:PIO3 value:LOW];
    }
}
- (IBAction)PIO4Pushed:(UISwitch *)sender{
    if(sender.on == YES){
        [Konashi digitalWrite:PIO4 value:HIGH];
    } else {
        [Konashi digitalWrite:PIO4 value:LOW];
    }
}
- (IBAction)PIO5Pushed:(UISwitch *)sender{
    if(sender.on == YES){
        [Konashi digitalWrite:PIO5 value:HIGH];
    } else {
        [Konashi digitalWrite:PIO5 value:LOW];
    }
}

// AnalogRead:AIO0
- (void)onReadAio0Timer:(NSTimer*)timer{
    [Konashi analogReadRequest:AIO0];
}
- (void)readAio0{
    int val = [Konashi analogRead:AIO0];
    aio0LabelText = [NSString stringWithFormat:@"%d", val];
    [aio0Label setText:aio0LabelText];
    aio0ProgView.progress = (float)val/1300;
    //NSLog(@"READ_AIO0: %d", val);
}

// AnalogRead:AIO1
- (void)onReadAio1Timer:(NSTimer*)timer{
    [Konashi analogReadRequest:AIO1];
}
- (void)readAio1{
    int val = [Konashi analogRead:AIO1];
    aio1LabelText = [NSString stringWithFormat:@"%d", val];
    [aio1Label setText:aio1LabelText];
    aio1ProgView.progress = (float)val/1300;
    //NSLog(@"READ_AIO1: %d", val);
}

// AnalogRead:AIO2
- (void)onReadAio2Timer:(NSTimer*)timer{
    [Konashi analogReadRequest:AIO2];
}
- (void)readAio2{
    int val = [Konashi analogRead:AIO2];
    aio2LabelText = [NSString stringWithFormat:@"%d", val];
    [aio2Label setText:aio2LabelText];
    aio2ProgView.progress = (float)val/1300;
    //NSLog(@"READ_AIO2: %d", val);
}

@end
