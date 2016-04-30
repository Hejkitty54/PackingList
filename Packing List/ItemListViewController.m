//
//  ItemListViewController.m
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import "ItemListViewController.h"

@interface ItemListViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@end

@implementation ItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ListTableView.dataSource=self;
    self.ListTableView.delegate=self;
    
    if ([Data singleton].allList != nil) {
        // makes a new array with two default items
        self.listData =@[@{@"name":@"Passport",@"checked":@"no"}.mutableCopy,
                         @{@"name":@"Ticket",@"checked":@"no"}.mutableCopy].mutableCopy;
        
        // if there are saved lists they will be shown on the list
        for (NSMutableDictionary* oneOfList in [Data singleton].allList) {
            
            if ([[oneOfList objectForKey:@"country"] isEqualToString:[Data singleton].tempCountry]) {
                [self.listData removeObjectAtIndex:0];
                [self.listData removeObjectAtIndex:0];
                NSArray* items = [oneOfList objectForKey:@"oneList"];
            
                for ( int i = 0; i < items.count; i++) {
                    NSArray* item =[items objectAtIndex:i];
                    item = item.mutableCopy;
                    [self.listData addObject:item];
                }
            }
        }
    }
    //for keybord
    self.itemTextField.delegate = self;
}

//keybord
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//for tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //gets a cell
    UITableViewCell *tvcell = [tableView dequeueReusableCellWithIdentifier: @"itemCell"];
    
    if (tvcell == nil) {
        tvcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: @"itemCell"];
    }
    
    //gets one item of the list
    NSDictionary* item = self.listData[[indexPath row]];
    NSString* itemName = [item objectForKey:@"name"];
    
    //shows the name on each cell
    tvcell.textLabel.text = itemName;
    
    if ([[item objectForKey:@"checked"]isEqualToString:@"yes"]) {
        tvcell.backgroundColor = [UIColor colorWithRed:0.98 green:0.80 blue:0.61 alpha:0.6];
    }else{
        tvcell.backgroundColor = [UIColor whiteColor];
    }
    
    tvcell.textLabel.font = [UIFont fontWithName:@"Geotica 2012" size:16.0];
    return tvcell;
}

- (IBAction)add:(id)sender {
    NSMutableDictionary* item = @{@"name":self.itemTextField.text,@"checked":@"no"}.mutableCopy;
    int count=0;
    
    for( NSMutableDictionary* item in self.listData){
        if ([[item objectForKey:@"checked"]isEqualToString:@"no"]) {
            count++;
        }
    }
    
    [self.listData insertObject:item atIndex:count];
    [self.ListTableView reloadData];
    self.itemTextField.text = @"";
}

- (IBAction)save:(id)sender {
    NSMutableDictionary *countryAndOneList = @{@"country":[Data singleton].tempCountry.mutableCopy,
                                               @"oneList":self.listData.mutableCopy}.mutableCopy;
    
    int count=0;
    int place=0;
    
    for (int i = 0 ; i < [Data singleton].allList.count ; i++) {
        if ([[[Data singleton].allList[i] objectForKey:@"country"] isEqualToString:[Data singleton].tempCountry]) {
            count++;
            place = i;
        }
    }
    
    if (count == 0) {
        [[Data singleton].allList addObject:countryAndOneList];
    }else{
        [[Data singleton].allList[place] setObject:self.listData forKey:@"oneList"];
    }
        
    [self dismissViewControllerAnimated:YES completion:nil];
}

//the action when the user touches items
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = indexPath.row;
    NSUInteger lastIndex = self.listData.count - 1;
    
    //if the item is unmarked,it will be marked and listed on the bottom of the list.
    if ([[[self.listData objectAtIndex:index] objectForKey:@"checked"] isEqualToString:@"no"]) {
        [[self.listData objectAtIndex:index] setValue:@"yes" forKey:@"checked"];
        
        NSString* temp = self.listData[index];
        
        [self.listData removeObjectAtIndex:index];
        [self.listData addObject:temp];
        
        // change place with animation
        [self.ListTableView beginUpdates];
        [self.ListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.ListTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastIndex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.ListTableView endUpdates];
        
    }// if item is marked, it will be unmarked and listed on the bottom of the items which is unmarked.
    else{
        
        NSString* temp = self.listData[index];
        [self.listData removeObjectAtIndex:index];
        
        int count = 0;
        
        for( NSDictionary* item in self.listData){
            if ([[item objectForKey:@"checked"]isEqualToString:@"no"]) {
                count++;
            }
        }
        
        [temp setValue:@"no" forKey:@"checked"];
        [self.listData insertObject:temp atIndex:count];
        
        // changes place with animation
        [self.ListTableView beginUpdates];
        [self.ListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.ListTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.ListTableView endUpdates];
    }
}

// for delete
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @[
             [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                title:@"Delete"
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                 
                                                  [self.listData removeObjectAtIndex:indexPath.row];
                                                  [self.ListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                              }]
             ];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
