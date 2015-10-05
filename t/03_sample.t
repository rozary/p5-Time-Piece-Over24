use Test::More tests => 3; 
use Time::Piece::Over24;

my $t    = localtime(1420037999); #2014-12-31 23:59:59

subtest "not over24 parse" => sub { 
  my $t = $t->from_over24_datetime("2014-12-31 19:00:00");
  is $t->over24_datetime, "2014-12-31 19:00:00";
};

subtest "over24 parse and end time test" => sub {
  diag("parse 2014-12-31 26:59:59");
  my $over = $t->from_over24_datetime("2014-12-31 26:59:59"); #2015-01-01 02:59:59
  $over->over24_offset('03:00:00'); #[03:00:00 - 26:59:59]

  is $over->hms, "02:59:59", sprintf( "%s normal hms %s", '26:59:59', '02:59:59' );
  is $over->over24_datetime, "2014-12-31 26:59:59", sprintf( "over datetime %s", '2014-12-31 26:59:59' );
  is $over->over24_time, "26:59:59", sprintf( "over time %s", '26:59:59' );
  is $over->over24_year, "2014";
  is $over->over24_mon, "12";
  is $over->over24_mday, "31";
  is $over->over24_hour, "26";

  subtest "offset clear" => sub {
    $over->over24_offset('00:00:00'); #[00:00:00 - 23:59:59]
    is $over->over24_datetime, "2015-01-01 02:59:59";
    is $over->over24_time, "02:59:59";
    is $over->over24_year, "2015";
    is $over->over24_mon, "1";
    is $over->over24_mday, "1";
    is $over->over24_hour, "2";
  }
};

subtest "start time test" => sub {
  my $over = $t->from_over24_time("26:59:59"); #2015-03-24 02:59:59
  $over->over24_offset('03:00:00'); #[03:00:00 - 26:59:59]
  $over += 1;
  is $over->over24_datetime, "2015-01-01 03:00:00", sprintf( "over24_datetime start time %s", '2015-01-01 03:00:00(27:00:00)' );
  is $over->over24_time, "03:00:00", sprintf( "over24_time parse %s", '03:00:00(27:00:00)' );
  is $over->over24_year, "2015";
  is $over->over24_mon, "1";
  is $over->over24_mday, "1";
  is $over->over24_hour, "3";
};

done_testing(3);
