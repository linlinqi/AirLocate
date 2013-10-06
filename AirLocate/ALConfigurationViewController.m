/*
     File: ALConfigurationViewController.m
 Abstract: Illustrates how to configure an iOS device as a beacon.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "ALConfigurationViewController.h"
#import "ALDefaults.h"

#import <CoreLocation/CoreLocation.h>

@interface ALConfigurationViewController ()

- (void)configurationChanged:(id)sender;

@end

@implementation ALConfigurationViewController
{
    CBPeripheralManager *_peripheralManager;
    
    BOOL _enabled;
    NSUUID *_uuid;
    NSNumber *_major;
    NSNumber *_minor;
    NSNumber *_power;
    
    UISwitch *_enabledSwitch;
    
    UITextField *_uuidTextField;
    UIPickerView *_uuidPicker;
    
    NSNumberFormatter *_numberFormatter;
    UITextField *_majorTextField;
    UITextField *_minorTextField;
    UITextField *_powerTextField;
    
    UIBarButtonItem *_doneButton;
    UIBarButtonItem *_saveButton;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if(self)
	{
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _uuid = [ALDefaults sharedDefaults].defaultProximityUUID;
        _power = [ALDefaults sharedDefaults].defaultPower;
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	}
	
	return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // Refresh the enabled switch.
    _enabled = _enabledSwitch.on = _peripheralManager.isAdvertising;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Configure";
    
    _enabledSwitch = [[UISwitch alloc] init];
    [_enabledSwitch addTarget:self action:@selector(configurationChanged:) forControlEvents:UIControlEventValueChanged];
    
    _uuidPicker = [[UIPickerView alloc] init];
    _uuidPicker.delegate = self;
    _uuidPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _uuidPicker.showsSelectionIndicator = YES;
    
    _uuidTextField = [[UITextField alloc] initWithFrame:CGRectMake(90.0f, 10.0f, 205.0f, 30.0f)];
    _uuidTextField.clearsOnBeginEditing = NO;
    _uuidTextField.textAlignment = NSTextAlignmentRight;
    _uuidTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;    
    _uuidTextField.inputView = _uuidPicker;
    _uuidTextField.delegate = self;
    
    _majorTextField = [[UITextField alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    _majorTextField.clearsOnBeginEditing = NO;
    _majorTextField.textAlignment = NSTextAlignmentRight;
    _majorTextField.keyboardType = UIKeyboardTypeNumberPad;
    _majorTextField.returnKeyType = UIReturnKeyDone;
    _majorTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _majorTextField.delegate = self;
    
    _minorTextField = [[UITextField alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    _minorTextField.clearsOnBeginEditing = NO;
    _minorTextField.textAlignment = NSTextAlignmentRight;
    _minorTextField.keyboardType = UIKeyboardTypeNumberPad;
    _minorTextField.returnKeyType = UIReturnKeyDone;
    _minorTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _minorTextField.delegate = self;
    
    _powerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    _powerTextField.clearsOnBeginEditing = NO;
    _powerTextField.textAlignment = NSTextAlignmentRight;
    _powerTextField.keyboardType = UIKeyboardTypeNumberPad;
    _powerTextField.returnKeyType = UIReturnKeyDone;
    _powerTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _powerTextField.delegate = self;
    
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(configurationChanged:)];
    _saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(configurationChanged:)];
    self.navigationItem.rightBarButtonItem = _saveButton;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Configure Device";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    switch(indexPath.row)
    {
        case 0:
        {
            // Enabled
            cell.textLabel.text = @"Enabled";
            cell.accessoryView = _enabledSwitch;
            break;
        }
            
        case 1:
        {
            // Proximity UUID
            cell.textLabel.text = @"UUID";
            _uuidTextField.text = [_uuid UUIDString];
            [cell.contentView addSubview:_uuidTextField];
            break;
        }
            
        case 2:
        {
            // Major
            cell.textLabel.text = @"Major";
            _majorTextField.text = [_major stringValue];
            [cell.contentView addSubview:_majorTextField];
            break;
        }
            
        case 3:
        {
            // Minor
            cell.textLabel.text = @"Minor";
            _minorTextField.text = [_minor stringValue];
            [cell.contentView addSubview:_minorTextField];
            break;
        }
            
        case 4:
        {
            // Measured Power
            cell.textLabel.text = @"Measured Power";
            _powerTextField.text = [_power stringValue];
            [cell.contentView addSubview:_powerTextField];
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _uuidPicker)
    {
        return [ALDefaults sharedDefaults].supportedProximityUUIDs.count;
    }
    
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if(pickerView == _uuidPicker)
    {
        UILabel *label = (UILabel *)view;
        if(!label)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 60.0f)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
        }
        
        label.text = [[[ALDefaults sharedDefaults].supportedProximityUUIDs objectAtIndex:row] UUIDString];
        
        return label;
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == _uuidPicker)
    {
        _uuid = [[ALDefaults sharedDefaults].supportedProximityUUIDs objectAtIndex:row];
        _uuidTextField.text = [_uuid UUIDString];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = _doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _majorTextField)
    {
        _major = [_numberFormatter numberFromString:textField.text];
    }
    else if(textField == _minorTextField)
    {
        _minor = [_numberFormatter numberFromString:textField.text];
    }
    else if(textField == _powerTextField)
    {
        _power = [_numberFormatter numberFromString:textField.text];
    }
    
    self.navigationItem.rightBarButtonItem = _saveButton;
}

- (void)configurationChanged:(id)sender
{
    if(sender == _enabledSwitch)
    {
        _enabled = _enabledSwitch.on;
    }
    else if(sender == _doneButton)
    {
        [_uuidTextField resignFirstResponder];
        [_majorTextField resignFirstResponder];
        [_minorTextField resignFirstResponder];
        [_powerTextField resignFirstResponder];
        
        [self.tableView reloadData];
    }
    else if(sender == _saveButton)
    {
        if(_peripheralManager.state < CBPeripheralManagerStatePoweredOn)
        {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth must be enabled" message:@"To configure your device as a beacon" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            
            return;
        }
        
        if(_enabled)
        {
            // We must construct a CLBeaconRegion that represents the payload we want the device to beacon.
            NSDictionary *peripheralData = nil;
            if(_uuid && _major && _minor)
            {
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:[_major shortValue] minor:[_minor shortValue] identifier:@"com.apple.AirLocate"];
                peripheralData = [region peripheralDataWithMeasuredPower:_power];
            }
            else if(_uuid && _major)
            {
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:[_major shortValue]  identifier:@"com.apple.AirLocate"];
                peripheralData = [region peripheralDataWithMeasuredPower:_power];
            }
            else if(_uuid)
            {
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.apple.AirLocate"];
                peripheralData = [region peripheralDataWithMeasuredPower:_power];
            }
            
            // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
            if(peripheralData)
            {
                [_peripheralManager startAdvertising:peripheralData];
            }
        }
        else
        {
            [_peripheralManager stopAdvertising];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
