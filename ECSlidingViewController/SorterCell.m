//
//  SorterCell.m
//  ECSlidingViewController
//
//  Created by HengHong on 13/11/12.
//
//

#import "SorterCell.h"

@implementation SorterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)cancelSearch:(id)sender {
    self.searchTextField.text = @"";
    [self.searchTextField.delegate textFieldShouldReturn:self.searchTextField];
}


@end
