
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#include <UIKit/UIKit.h>

@interface MTAlarmEditView : UIView
  -(UIDatePicker*)timePicker;
@end

@interface MTAAlarmEditViewController : UIViewController
  -(MTAlarmEditView*)view;
@end

@interface MTUIDigitalClockLabel
@end

@interface MTUIAlarmView : UIView
  @property (assign,nonatomic) MTUIDigitalClockLabel *timeLabel;
@end

%group iOS11
    %hook MTAAlarmEditViewController

    - (void)_doneButtonClicked: (id)arg
    {
        BOOL warnPM = YES;
        BOOL warnAM = NO;

        NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/jzplusplus.PMreally.plist"]];

        if (plist) { // Preference file exists
            NSNumber *pref = [plist objectForKey:@"pm"];
            if (pref) warnPM = [pref boolValue];

            pref = [plist objectForKey:@"am"];
            if (pref) warnAM = [pref boolValue];
        }

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"a"];
        NSString * ampm = [formatter stringFromDate:[[[self view] timePicker] date]];
        [formatter release];

        if( (warnPM && [ampm characterAtIndex:0] == 'P') || (warnAM && [ampm characterAtIndex:0] == 'A') )
        {
            NSString *title = [ampm stringByAppendingString:@", really?"];
            NSString *msg = [@"Did you really mean to set this alarm for " stringByAppendingString:[ampm stringByAppendingString:@"?"]];

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:msg
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I did."
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action)
                                                                           {
                                                                               %orig(arg);
                                                                           }
                                           ];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Nope!"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                                                    {
                                                                        NSDate *d = [[(MTAlarmEditView*)[self view] timePicker] date];
                                                                        int offset = -43200;
                                                                        if([ampm characterAtIndex:0] == 'A') offset = 43200;
                                                                        d = [d dateByAddingTimeInterval: offset]; //subtract 12 hours
                                                                        [[[self view] timePicker] setDate:d animated:YES];
                                                                    }
                                       ];

            [alertController addAction:cancelAction];
            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }
        else %orig(arg);
    }

    %end

    %hook MTAAlarmTableViewController

    -(void)setAlarmEnabled:(BOOL)arg1 forCell:(id)arg2
    {
      if (arg1)
      {
        MTUIAlarmView *alarmView = MSHookIvar<MTUIAlarmView*>(arg2,"_alarmView");
        int hour = MSHookIvar<int>(alarmView.timeLabel,"_hour");

        BOOL warnPM = YES;
        BOOL warnAM = NO;
        BOOL warnOnSwitch = YES;
        NSString *ampm = @"PM";

        NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/jzplusplus.PMreally.plist"]];

        if (plist) { // Preference file exists
            NSNumber *pref = [plist objectForKey:@"pm"];
            if (pref) warnPM = [pref boolValue];

            pref = [plist objectForKey:@"am"];
            if (pref) warnAM = [pref boolValue];

            pref = [plist objectForKey:@"switching"];
            if (pref) warnOnSwitch = [pref boolValue];
        }

        if(hour < 12) ampm = @"AM";

        if( warnOnSwitch && ( (warnPM && hour >= 12) || (warnAM && hour < 12) ))
        {
            NSString *title = [ampm stringByAppendingString:@", really?"];
            NSString *msg = [@"Did you really mean to set this alarm for " stringByAppendingString:[ampm stringByAppendingString:@"?"]];

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:msg
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I did."
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action)
                                           {
                                               %orig(arg1,arg2);
                                           }
                                           ];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Nope!"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action){
                                                               %orig(NO,arg2);
                                                             }
                                       ];

            [alertController addAction:cancelAction];
            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }
        else %orig(arg1,arg2);
      }
      else
        %orig(arg1,arg2);
    }

    -(void)activeChangedForAlarm:(id)arg1 active:(BOOL)arg2
    {
        BOOL warnPM = YES;
        BOOL warnAM = NO;
        BOOL warnOnSwitch = YES;
        NSString *ampm = @"PM";

        NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/jzplusplus.PMreally.plist"]];

        if (plist) { // Preference file exists
            NSNumber *pref = [plist objectForKey:@"pm"];
            if (pref) warnPM = [pref boolValue];

            pref = [plist objectForKey:@"am"];
            if (pref) warnAM = [pref boolValue];

            pref = [plist objectForKey:@"switching"];
            if (pref) warnOnSwitch = [pref boolValue];
        }

        if([arg1 hour] < 12) ampm = @"AM";

        if( warnOnSwitch && (arg2 == YES) &&
           ( (warnPM && [arg1 hour] >= 12) || (warnAM && [arg1 hour] < 12) ))
        {
            NSString *title = [ampm stringByAppendingString:@", really?"];
            NSString *msg = [@"Did you really mean to set this alarm for " stringByAppendingString:[ampm stringByAppendingString:@"?"]];

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:msg
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I did."
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action)
                                           {
                                               %orig(arg1, arg2);
                                           }
                                           ];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Nope!"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action){}
                                       ];

            [alertController addAction:cancelAction];
            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }
        else %orig(arg1, arg2);
    }

    %end
%end

%group iOS10
    %hook EditAlarmViewController

    - (void)_doneButtonClicked: (id)arg
    {
        BOOL warnPM = YES;
        BOOL warnAM = NO;

        NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/jzplusplus.PMreally.plist"]];

        if (plist) { // Preference file exists
            NSNumber *pref = [plist objectForKey:@"pm"];
            if (pref) warnPM = [pref boolValue];

                pref = [plist objectForKey:@"am"];
                if (pref) warnAM = [pref boolValue];
                    }

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"a"];
        NSString * ampm = [formatter stringFromDate:[[(MTAlarmEditView*)[self view] timePicker] date]];
        [formatter release];

        if( (warnPM && [ampm characterAtIndex:0] == 'P') || (warnAM && [ampm characterAtIndex:0] == 'A') )
        {
            NSString *title = [ampm stringByAppendingString:@", really?"];
            NSString *msg = [@"Did you really mean to set this alarm for " stringByAppendingString:[ampm stringByAppendingString:@"?"]];

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:msg
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I did."
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action)
                                           {
                                               %orig(arg);
                                           }
                                           ];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Nope!"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                       {
                                           NSDate *d = [[(MTAlarmEditView*)[self view] timePicker] date];
                                           int offset = -43200;
                                           if([ampm characterAtIndex:0] == 'A') offset = 43200;
                                           d = [d dateByAddingTimeInterval: offset]; //subtract 12 hours
                                           [[(MTAlarmEditView*)[self view] timePicker] setDate:d animated:YES];
                                       }
                                       ];

            [alertController addAction:cancelAction];
            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }
        else %orig(arg);
            }

    %end

    %hook AlarmViewController

    -(void)activeChangedForAlarm:(id)arg1 active:(BOOL)arg2
    {
        BOOL warnPM = YES;
        BOOL warnAM = NO;
        BOOL warnOnSwitch = YES;
        NSString *ampm = @"PM";

        NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/jzplusplus.PMreally.plist"]];

        if (plist) { // Preference file exists
            NSNumber *pref = [plist objectForKey:@"pm"];
            if (pref) warnPM = [pref boolValue];

                pref = [plist objectForKey:@"am"];
                if (pref) warnAM = [pref boolValue];

                    pref = [plist objectForKey:@"switching"];
                    if (pref) warnOnSwitch = [pref boolValue];
                        }

        if([arg1 hour] < 12) ampm = @"AM";

            if( warnOnSwitch && (arg2 == YES) &&
               ( (warnPM && [arg1 hour] >= 12) || (warnAM && [arg1 hour] < 12) ))
            {
                NSString *title = [ampm stringByAppendingString:@", really?"];
                NSString *msg = [@"Did you really mean to set this alarm for " stringByAppendingString:[ampm stringByAppendingString:@"?"]];

                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                         message:msg
                                                                                  preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I did."
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction *action)
                                               {
                                                   %orig(arg1, arg2);
                                               }
                                               ];

                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Nope!"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action){}
                                           ];

                [alertController addAction:cancelAction];
                [alertController addAction:okAction];

                [self presentViewController:alertController animated:YES completion:nil];
            }
            else %orig(arg1, arg2);
                }

    %end
%end

// iOS 11 changed the class names
%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
        %init(iOS11);
    } else {
        %init(iOS10);
    }
}
