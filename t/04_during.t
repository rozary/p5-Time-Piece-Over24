use Test::More tests => 5; 
use Time::Piece::Over24;

subtest "is_during normal time and at now" => sub {
  my $t    = localtime(1420037999); #2014-12-31 23:59:59
  my $rtn = $t->is_during("2014-12-31 23:59:57","2014-12-31 23:59:58");
  is $rtn , undef;

  $rtn = $t->is_during("2014-12-31 23:59:59","2015-01-01 00:00:00");
  is $rtn , 1;

  $rtn = $t->is_during("2015-01-01 00:00:00","2015-01-01 00:00:01");
  is $rtn , undef;
};

subtest "is_during over time and at now" => sub {
  my $over    = localtime(1420048799); #2015-01-01  02:59:59
  my $rtn = $over->is_during("2014-12-31 23:59:57","2014-12-31 26:59:58");
  is $rtn , undef;

  $rtn = $over->is_during("2014-12-31 26:59:59","2014-12-31 27:00:00");
  is $rtn , 1;

  $rtn = $over->is_during("2015-01-01 27:00:00","2015-01-01 00:00:01");
  is $rtn , undef;
};

subtest "is_during over time(timepiece) and at now" => sub {
  my $over    = localtime(1420048799); #2015-01-01  02:59:59

#  say localtime->from_mysql_datetime("2014-12-31 23:59:57")->epoch;
#  say localtime->from_over24_datetime("2014-12-31 26:59:58")->epoch;

  my $s_t = localtime(1420037997);
  my $e_t = localtime(1420048798);
  my $rtn = $over->is_during($s_t,$e_t);
  is $rtn , undef;

  $s_t = localtime(1420048799);
  $e_t = localtime(1420048800);
  $rtn = $over->is_during($s_t,$e_t);
  is $rtn , 1;

  $s_t = localtime(1420048800);
  $e_t = localtime(1420048801);
  $rtn = $over->is_during($s_t,$e_t);
  is $rtn , undef;
};

subtest "is_during over time(timepiece) and at appointed time" => sub {
  my $t    = localtime();
  my $appointed_t    = "2015-01-01 02:59:59"; #2015-01-01  02:59:59

  my $s_t = localtime(1420037997);
  my $e_t = localtime(1420048798);
  my $rtn = $t->is_during($s_t,$e_t,$appointed_t);
  is $rtn , undef;

  $s_t = localtime(1420048799);
  $e_t = localtime(1420048800);
  $rtn = $t->is_during($s_t,$e_t,$appointed_t);
  is $rtn , 1;

  $s_t = localtime(1420048800);
  $e_t = localtime(1420048801);
  $rtn = $t->is_during($s_t,$e_t,$appointed_t);
  is $rtn , undef;
};

subtest "is_during over time(timepiece) and at appointed time(timepiece)" => sub {
  my $t    = localtime();
  my $appointed_t    = localtime(1420048799); #2015-01-01  02:59:59

  my $s_t = localtime(1420037997);
  my $e_t = localtime(1420048798);
  my $rtn = $t->is_during($s_t,$e_t,$appointed_t);
  is $rtn , undef;

  $s_t = localtime(1420048799);
  $e_t = localtime(1420048800);
  $rtn = $t->is_during($s_t,$e_t,$appointed_t);
  is $rtn , 1;

  $s_t = localtime(1420048800);
  $e_t = localtime(1420048801);
  $rtn = $t->is_during($s_t,$e_t,$appointed_t);
  is $rtn , undef;
};

done_testing(5);
