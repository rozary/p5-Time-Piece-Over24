use strict;
use warnings;

BEGIN {
#  $ENV{TZ} = "WET";
};

#print $^O;
#darwin
use lib "~/git/p5-Time-Piece-Over24/lib/";

use Test::More tests => 1;
use Time::Piece::MySQL;
use Time::Piece::Over24;

my $hms = ["5","5","5"];
my $sec = localtime->_hms_to_sec($hms);
is $sec, 18305, "_hms_to_sec";

done_testing;
