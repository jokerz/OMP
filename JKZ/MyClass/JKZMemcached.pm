#******************************************************
# $Id: ,v 1.0 2011/11/25 RyoIwahase Exp $
# @desc      
# @package   MyClass::JKZMemcached
# @access    
# @author    Iwahase Ryo
# @create    2011/11/25
# @update    
# @version   1.0
#******************************************************
package MyClass::JKZMemcached;

use strict;
use warnings;
use Cache::Memcached::Fast;

my $MemcachedFast;


sub new {
    my $class   = shift;
    my $cfg     = @_ ? shift
                :
                {
                    servers            => ["127.0.0.1:11211"],
                    #servers            => ["192.168.1.200:11211"],
                    #servers            => ["192.168.10.30:11211"],
                    #servers            => ["192.168.10.30:11211"],
                    namespace          => 'dOMP:',
                    compress_threshold => 10_000,
                    compress_ratio     => 0.9,
                }
                ;

    my $self    = bless {}, $class;

    if ( !$MemcachedFast ) {
        $MemcachedFast = Cache::Memcached::Fast->new($cfg);
    }
    $self->{_memcachedfast} = $MemcachedFast;

    return $self;
}


sub get {
    my $self = shift;
    $self->{_memcachedfast}->get(@_);
}


sub add {
    my $self = shift;
    $self->{_memcachedfast}->add(@_);
}


sub replace {
    my $self = shift;
    $self->{_memcachedfast}->replace(@_);
}


sub delete {
    my $self = shift;
    $self->{_memcachedfast}->delete(@_);
}


sub flush_all {
    my $self = shift;
    $self->{_memcachedfast}->flush_all();
}

1;
__END__