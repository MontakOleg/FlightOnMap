#import "AirportAnnotationView.h"

#define UIColorFromRGB(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:alphaValue]


@interface AirportAnnotationView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation AirportAnnotationView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = UIColorFromRGB(0xE8CA39, 0.8);
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.cornerRadius = self.bounds.size.height / 2;
    
    CGFloat leftAndRightPadding = 5;
    CGFloat topAndBottomPadding = 2;
    self.titleLabel.frame = CGRectMake(leftAndRightPadding,
                                       topAndBottomPadding,
                                       self.bounds.size.width - leftAndRightPadding * 2,
                                       self.bounds.size.height - topAndBottomPadding * 2);
}

@end
