use strict;
use warnings;

use 5.21.2;
BEGIN {
#  $ENV{TZ} = "WET";
};

#print $^O;
#darwin
use lib "~/git/p5-Time-Piece-Over24/lib/";

use Test::More tests => 2;
use Time::Piece::MySQL;
use Time::Piece::Over24;

subtest "normal time" => sub {
  my $t = localtime->_from_over24("2015-10-04 23:59:59");
  my $t_expected = localtime->from_mysql_datetime("2015-10-04 23:59:59");
  is $t, $t_expected, "_from_over24 normal time";
};

subtest "over time" => sub {
  my $t = localtime->_from_over24("2015-10-04 26:59:59");
  my $t_expected = localtime->from_mysql_datetime("2015-10-05 02:59:59");
  is $t, $t_expected, "_from_over24 over time";
};


done_testing;
