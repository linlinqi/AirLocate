/*
     File: ALCalibrationBeginViewController.m
 Abstract: View controller for bootstrapping the calibration process.
 
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

#import "ALCalibrationBeginViewController.h"
#import "ALCalibrationEndViewController.h"
#import "ALCalibrationCalculator.h"
#import "ALDefaults.h"

@interface ALCalibrationBeginViewController()

- (void)startRangingAllRegions;
- (void)stopRangingAllRegions;

@end

@implementation ALCalibrationBeginViewController
{
    NSMutableDictionary *_beacons;
    CLLocationManager *_locationManager;
    NSMutableArray *_rangedRegions;
    
    UIProgressView *_progressBar;
    BOOL _inProgress;
    
    ALCalibrationCalculator *_calculator;
    ALCalibrationEndViewController *_endViewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if(self)
	{
        _beacons = [[NSMutableDictionary alloc] init];
        
        // This location manager will be used to display beacons available for calibration.
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _inProgress = NO;
	}
	
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{    
    // CoreLocation will call this delegate method at 1 Hz with updated range information.
    // Beacons will be categorized and displayed by proximity.
    [_beacons removeAllObjects];
    NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
    if([unknownBeacons count])
        [_beacons setObject:unknownBeacons forKey:[NSNumber numberWithInt:CLProximityUnknown]];
    
    NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
    if([immediateBeacons count])
        [_beacons setObject:immediateBeacons forKey:[NSNumber numberWithInt:CLProximityImmediate]];
    
    NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
    if([nearBeacons count])
        [_beacons setObject:nearBeacons forKey:[NSNumber numberWithInt:CLProximityNear]];
    
    NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
    if([farBeacons count])
        [_beacons setObject:farBeacons forKey:[NSNumber numberWithInt:CLProximityFar]];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Start ranging to show the beacons available for calibration.
    [self startRangingAllRegions];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Cancel calibration (if it was started) and stop ranging when the view goes away.
    [_calculator cancelCalibration];
    [self stopRangingAllRegions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Calibration";
    
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    // Populate the regions for the beacons we're interested in calibrating.
    _rangedRegions = [NSMutableArray array];
    [[ALDefaults sharedDefaults].supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
        NSUUID *uuid = (NSUUID *)uuidObj;
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        [_rangedRegions addObject:region];
    }];
    
    _endViewController = [[ALCalibrationEndViewController alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // A special indicator appears if calibration is in progress.
    // This is handled throughout the table view controller delegate methods.
    NSInteger i = _inProgress ? _beacons.count + 1 : _beacons.count;
    
    return i;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger i = section;
    if(_inProgress)
    {
        if(i == 0)
        {
            return 1;
        }
        else
        {
            i--;
        }
    }
    
    NSArray *sectionValues = [_beacons allValues];
    return [[sectionValues objectAtIndex:i] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger i = section;
    if(_inProgress)
    {
        if(i == 0)
        {
            return nil;
        }
        else
        {
            i--;
        }
    }
    
    NSString *title = nil;
    NSArray *sectionKeys = [_beacons allKeys];
    
    NSNumber *sectionKey = [sectionKeys objectAtIndex:i];
    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = @"Immediate";
            break;
            
        case CLProximityNear:
            title = @"Near";
            break;
            
        case CLProximityFar:
            title = @"Far";
            break;
            
        default:
            title = @"Unknown";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *beaconCellIdentifier = @"BeaconCell";
    static NSString *progressCellIdentifier = @"ProgressCell";
    
    NSInteger i = indexPath.section;
    NSString *identifier = _inProgress && i == 0 ? progressCellIdentifier : beaconCellIdentifier;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{        
        if(identifier == progressCellIdentifier)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            _progressBar.center = CGPointMake(cell.center.x, 17.0f);
            [cell.contentView addSubview:_progressBar];
            
            // Show the indicator that denotes calibration is in progress.
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 15.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            label.backgroundColor = [UIColor clearColor];
            label.center = CGPointMake(cell.center.x, 30.0f);
            label.font = [UIFont systemFontOfSize:11.0f];
            label.text = @"Wave device side-to-side 1m away from beacon";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:label];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
	}
    
    if(identifier == progressCellIdentifier)
    {
        return cell;
    }
    else if(_inProgress)
    {
        i--;
    }
    
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:i];
    CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    cell.textLabel.text = [beacon.proximityUUID UUIDString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@, Acc: %.2fm", beacon.major, beacon.minor, beacon.accuracy];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:indexPath.section];
    CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    if(!_inProgress)
    {
        CLBeaconRegion *region = nil;
        if(beacon.proximityUUID && beacon.major && beacon.minor)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:[beacon.major shortValue] minor:[beacon.minor shortValue] identifier:@"com.apple.AirLocate"];
        }
        else if(beacon.proximityUUID && beacon.major)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:[beacon.major shortValue] identifier:@"com.apple.AirLocate"];
        }
        else if(beacon.proximityUUID)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID identifier:@"com.apple.AirLocate"];
        }
        
        if(region)
        {
            // We can stop ranging to display beacons available for calibration.
            [self stopRangingAllRegions];
            
            // And we'll start the calibration process.
            _calculator = [[ALCalibrationCalculator alloc] initWithRegion:region completionHandler:^(NSInteger measuredPower, NSError *error) {
                if(error)
                {
                    // Only display if the view is showing.
                    if(self.view.window)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to calibrate device" message:[error.userInfo objectForKey:NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        
                        // Resume displaying beacons available for calibration if the calibration process failed.
                        [self startRangingAllRegions];
                    }
                }
                else
                {                    
                    _endViewController.measuredPower = measuredPower;
                    [self.navigationController pushViewController:_endViewController animated:YES];
                }
                
                _inProgress = NO;
                _calculator = nil;
                
                [self.tableView reloadData];
            }];
            
            [_calculator performCalibrationWithProgressHandler:^(float percentComplete) {
                [_progressBar setProgress:percentComplete animated:YES];
            }];
            
            _progressBar.progress = 0.0f;
            _inProgress = YES;
            
            [self.tableView reloadData];
        }
    }
}

- (void)startRangingAllRegions
{
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager startRangingBeaconsInRegion:region];
    }];
}

- (void)stopRangingAllRegions
{
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager stopRangingBeaconsInRegion:region];
    }];
}

@end
