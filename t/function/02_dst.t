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
#DSTに入るときは1時が2時になる1時00:59:59から02:00:00になる。

subtest "over time 形式のdst 前" => sub {
  my $t = localtime->_from_over24("2015-03-28 24:59:59");
  is $t->datetime , "2015-03-29T00:59:59";
};

subtest "over time 形式のdst 直後" => sub {
  my $t = localtime->_from_over24("2015-03-28 25:00:00");
  say $t;
  say $t->datetime;
  say $t->hms;
  say $t;
  say $t->epoch;
  say $t->datetime;
  is $t->datetime , "2015-03-29T02:00:00";
};

subtest "over time 形式のdst あと 2時" => sub {
  #パースする時1時は2時で2時は2時
  my $t = localtime->_from_over24("2015-03-28 26:00:00");
  say $t->epoch;
  is $t->datetime , "2015-03-29T02:00:00";
};

__END__
subtest "over time 形式のdst あと 2時" => sub {
  #パースする時1時は2時で2時は2時
  my $t = localtime->_from_over24("2015-03-28 50:00:00");
  is $t->datetime , "2015-03-30T02:00:00";
};

__END__

subtest "over time 形式じゃない dstの前" => sub {
  my $t = localtime->_from_over24("2015-03-29 00:59:59");
  is $t->datetime , "2015-03-29T00:59:59";
};

subtest "over time 形式じゃない dstの直後" => sub {
  my $t = localtime->_from_over24("2015-03-29 01:00:00");
  is $t->datetime , "2015-03-29T02:00:00";
};

subtest "over time 形式じゃない dst あと 2時" => sub {
  #パースする時1時は2時で2時は2時
  my $t = localtime->_from_over24("2015-03-29 02:00:00");
  is $t->datetime , "2015-03-29T02:00:00";
};

subtest "from_mysql_datetime" => sub {
  my $t = localtime->from_mysql_datetime("2015-03-29 01:00:00");
  is $t->datetime , "2015-03-29T01:00:00";
};

subtest "from_mysql_datetime" => sub {
  my $t = localtime->from_mysql_datetime("2015-03-29 02:00:00");
  is $t->datetime , "2015-03-29T02:00:00";
};

done_testing;
