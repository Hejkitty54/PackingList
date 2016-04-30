//
//  ItemListViewController.h
//  Packing List
//
//  Created by ITHS on 2016-04-19.
//  Copyright © 2016 Kozue Wendén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data.h"
@interface ItemListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *ListTableView;
@property (nonatomic) NSMutableArray* listData;
@end
