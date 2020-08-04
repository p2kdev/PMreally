#include <UIKit/UIKit.h>

@interface MTAlarmEditView : UIView
  -(UIDatePicker*)timePicker;
@end

@interface MTAAlarmEditViewController : UIViewController
  -(MTAlarmEditView*)view;
@end

@interface MTAAlarmTableViewController : UIViewController
@end

@interface MTUIDigitalClockLabel
@end

@interface MTUIAlarmView : UIView
  @property (assign,nonatomic) MTUIDigitalClockLabel *timeLabel;
@end

%hook MTAAlarmEditViewController

- (void)_doneButtonClicked: (id)arg1
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"a"];
    NSString * ampm = [formatter stringFromDate:[[[self view] timePicker] date]];

    if([ampm characterAtIndex:0] == 'P')
    {
        NSString *title = @"PM Confirm!";
        NSString *msg = @"Did you really mean to set this alarm as it's for PM?";

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I did."
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                                                       {
                                                                           %orig(arg1);
                                                                       }
                                       ];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Nope!"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                                                {
                                                                    NSDate *d = [[(MTAlarmEditView*)[self view] timePicker] date];
                                                                    int offset = -43200;
                                                                    d = [d dateByAddingTimeInterval: offset]; //subtract 12 hours
                                                                    [[[self view] timePicker] setDate:d animated:YES];
                                                                }
                                   ];

        [alertController addAction:cancelAction];
        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
    else %orig(arg1);
}

%end

%hook MTAAlarmTableViewController

-(void)setAlarmEnabled:(BOOL)arg1 forCell:(id)arg2
{
  if (arg1)
  {
    MTUIAlarmView *alarmView = MSHookIvar<MTUIAlarmView*>(arg2,"_alarmView");
    int hour = MSHookIvar<int>(alarmView.timeLabel,"_hour");

    if(hour >= 12)
    {
        NSString *title = @"PM Confirm!";
        NSString *msg = @"Did you really mean to set this alarm as it's for PM?";

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
    if([arg1 hour] >= 12)
    {
        NSString *title = @"PM Confirm!";
        NSString *msg = @"Did you really mean to set this alarm as it's for PM?";

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
