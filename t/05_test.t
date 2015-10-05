use 5.21.2;
use Test::More tests => 4; 
use Time::Piece::MySQL;
use Time::Piece::Over24;

my $t = localtime->over24_datetime("2010-12-31 00:00:00");
#$t->over24_offset("05:00:00");
#is $t->over24_datetime, "2010-12-31 47:00:00";
#say $t->over24_year;
#
is $t->datetime, "2010-12-31T00:00:00";
is $t->over24_datetime, "2010-12-31 00:00:00";

my $t = localtime->over24_datetime("2010-12-31 27:59:59");
#$t->over24_offset("05:00:00");
#is $t->over24_datetime, "2010-12-31 47:00:00";
#say $t->over24_year;

#[05:00:00 - 29:59:59]
$t->over24_offset("23:59:59"); #[23:59:59 - 27:59:58)]
is $t->datetime, "2011-01-01T00:00:00";
is $t->over24_datetime, "2010-12-31 24:00:00";
