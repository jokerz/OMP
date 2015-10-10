package MyClass::Plugin::SiteMap;

use strict;
use warnings;

#use base 'Class::Component::Plugin';
use base 'MyClass::Plugin';
use WebUtil;

sub siteMap :Method{
    my ($self, $c, $arg) = @_;
    my $obj;

    my @keywords = (
        undef,
        'Emoji',
        'PDeco',
        'Deco',
        'DecoTmplt',
        'Flash',
    );

    my $objfile = $c->CONFIGURATION_VALUE('SUBCATEGORYLIST_OBJ');

    my $objdata;

    eval {
        $objdata = WebUtil::publishObj( { file=>$objfile } );
    };

    foreach my $idx (1..$#keywords) {

        my $hashkey = sprintf("%s_", lc($keywords[$idx]));
        my $loopkey = sprintf("Loop%sSubCategoryList", $keywords[$idx]);
        for (my $i = 0; $i <= $#{ $objdata->[$idx] }; $i++) {
            map {
                if (defined( $objdata->[$idx]->[$i]->{$_} )) {
                    push @{$obj->{$hashkey . $_}}, $objdata->[$idx]->[$i]->{$_};
                    push @{$obj->{LISTMAINURL}}, $c->UI_MAINURL();
                }
            } keys %{ $objdata->[$idx]->[$i] };
        }
        $obj->{$loopkey} = $#{$obj->{$hashkey . 'category_id'}};
    }
    ## upstr030‚Ítmplt_id 32
    #$self->setTmpltID("32");
    ## ¤—p‚Ìtmplt_id 41#
    $c->setTmpltID("32");

    $obj;
}

sub class_component_plugin_attribute_detect_cache_enable { 0 }

1;