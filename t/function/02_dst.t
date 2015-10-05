use strict;
use warnings;
use 5.21.2;

BEGIN {
  $ENV{TZ} = "WET";
};

use Test::More tests => 5;
use Time::Piece::MySQL;
use Time::Piece::Over24;

#dst タイムゾーンで通常時間と越え時間をチェック
#dst じゃないタイムゾーンで通常時間と越え時間をチェック は _from_over24.tでテストしてる

subtest "normal time" => sub {
  my $t = localtime->_from_over24("2015-03-28 23:00:00");
  my $t_expected = localtime->from_mysql_datetime("2015-03-28 23:00:00");
  is $t, $t_expected, "_from_over24 normal time";
};

subtest "over time" => sub {
  my $t = localtime->_from_over24("2015-03-28 25:00:00");
  my $t_expected = localtime->from_mysql_datetime("2015-03-29 01:00:00");
  say $t_expected;
  is $t, $t_expected, "_from_over24 over time";
};

subtest "over time" => sub {
  my $t = localtime->_from_over24("2015-03-28 25:30:00");
  my $t_expected = localtime->from_mysql_datetime("2015-03-29 01:30:00");
  say $t_expected;
  is $t, $t_expected, "_from_over24 over time";
};


subtest "dst over time" => sub {
  my $t = localtime->_from_over24("2015-03-28 25:00:00");
  my $t_expected = localtime->from_mysql_datetime("2015-03-29 02:00:00");
  say $t_expected;
  is $t, $t_expected, "_from_over24 over time";
};

#2400 は 0じ
#2500 は 2時
subtest "dst over time" => sub {
  my $t = localtime->_from_over24("2015-03-28 25:30:00");
  my $t_expected = localtime->from_mysql_datetime("2015-03-29 02:30:00");
  say $t_expected;
  is $t, $t_expected, "_from_over24 over time";
};

#26:30は02:30じゃなくて03:30
#25:30は01:30じゃなくて02:30
subtest "dst over time" => sub {
  my $t = localtime->_from_over24("2015-03-28 25:30:00");
  say $t;
  my $t_expected = localtime->from_mysql_datetime("2015-03-29 02:30:00");
  say $t_expected;
  is $t, $t_expected, "_from_over24 over time";
};

subtest "dst over time" => sub {
#こいつは01:30であるべき
  my $t = localtime->_from_over24("2015-03-29 01:30:00");
  say "###";
  say $t;
  say "###";
  my $t_expected = localtime->from_mysql_datetime("2015-03-29 02:30:00");
  say $t_expected;
  is $t, $t_expected, "_from_over24 over time";
};

done_testing;
