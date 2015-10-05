use Test::More tests => 2; 
use Time::Piece::Over24;

my $t = localtime->over24_datetime("2014-12-31 24:00:00");
$t->over24_offset("00:00:01"); #[00:00:01 - 24:00:00]
is $t->datetime, "2015-01-01T00:00:00";
is $t->over24_datetime, "2014-12-31 24:00:00";
