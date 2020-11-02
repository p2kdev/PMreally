#include <UIKit/UIKit.h>

@interface MTAlarmEditView : UIView
  -(UIDatePicker*)timePicker;
@end

@interface MTAAlarmEditViewController : UIViewController
  -(MTAlarmEditView*)view;
  -(UIDatePicker*)timePicker;
@end

@interface MTAAlarmTableViewController : UIViewController
@end

@interface MTUIDigitalClockLabel
@end

@interface MTAAlarmTableViewCell : UIView
  @property (assign,nonatomic) MTUIDigitalClockLabel *digitalClockLabel;
@end

%hook MTAAlarmEditViewController

- (void)_doneButtonClicked: (id)arg1
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"a"];
    NSString * ampm = [formatter stringFromDate:[[self timePicker] date]];

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
                                                                    NSDate *d = [[self timePicker] date];
                                                                    int offset = -43200;
                                                                    d = [d dateByAddingTimeInterval: offset]; //subtract 12 hours
                                                                    [[self timePicker] setDate:d animated:YES];
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

-(void)setAlarmEnabled:(BOOL)arg1 forCell:(MTAAlarmTableViewCell*)arg2
{
  if (arg1)
  {
    int hour = MSHookIvar<int>(arg2.digitalClockLabel,"_hour");

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
