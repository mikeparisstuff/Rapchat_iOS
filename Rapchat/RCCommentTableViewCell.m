//
//  RCCommentTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 12/17/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCCommentTableViewCell.h"

@interface RCCommentTableViewCell()

@property RCComment *comment;

@end

@implementation RCCommentTableViewCell

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

- (void)setCellComment:(RCComment *)comment
{
    self.comment = comment;
//    self.commentTextView.frame = CGRectMake(self.commentTextView.frame.origin.x, self.commentTextView.frame.origin.y, self.commentTextView.frame.size.width, [self textViewHeightForText:self.comment.text]);
    self.commentTextView.contentInset = UIEdgeInsetsMake(-4,-5,0,0);
    self.usernameLabel.text = comment.commenter;
    
    // Set frame of textview so that it fits text
    NSString *text = self.comment.text;
    self.commentTextView.text = text;
    
    // Set Date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *months = @[@"", @"Jan", @"Feb", @"March", @"Apr", @"May", @"June", @"July", @"Aug", @"Sep",  @"Oct", @"Nov", @"Dec"];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSArray *dateArray = [[dateFormatter stringFromDate:self.comment.created] componentsSeparatedByString:@"/"];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
}

- (CGFloat)textViewHeightForText:(NSString *)text {
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
    
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:attributed];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(280, FLT_MAX)];
    return size.height + 20;
}

@end
