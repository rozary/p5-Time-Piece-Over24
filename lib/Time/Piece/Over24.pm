package Time::Piece::Over24;

use 5.21.2;
use strict;
use warnings;
use vars qw/$VERSION/;
use Time::Piece;

$VERSION = "0.020";
my $OVER24_OFFSET   = '00:00:00';
my $OVER24_BASETIME = localtime;

sub import { shift; @_ = ( "Time::Piece", @_ ); goto &Time::Piece::import }

package Time::Piece;
use DDP;
use Storable qw/dclone/;

sub over24 {
    my ( $self, $time ) = @_;

    return $self->from_over24($time) if ($time);
    return $self->over24_datetime;
}

sub over24_time {
    my ( $self, $time ) = @_;
    return $self->from_over24_time($time) if ($time);

    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern;
    $hour = sprintf( "%02d", $hour );
    return $self->strftime("$hour:%M:%S");
}

sub over24_year {
    my ($self) = @_;

    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern;
    return $self->year;
}

sub over24_mon {
    my ($self) = @_;

    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern;
    return $self->mon;
}

sub over24_mday {
    my ($self) = @_;

    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern;
    return $self->mday;
}

sub over24_hour {
    my ($self) = @_;
    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern;
    return $hour;
}

sub over24_ymd {
    my ($self) = @_;
    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern;

    return $self->strftime("%Y-%m-%d $hour:%M:%S");
}

sub over24_datetime {
    my ( $self, $datetime ) = @_;
    return $self->from_over24_datetime($datetime) if ($datetime);

    my $hour;
    ( $self, $hour ) = $self->_over24_offset_pattern();
    $hour = sprintf( "%02d", $hour );
    return $self->strftime("%Y-%m-%d $hour:%M:%S");
}

sub from_over24 {
    my ( $self, $time ) = @_;
    if ( $time =~ /^\d\d:\d\d:\d\d$/ ) {
        return $self->from_over24_time($time);
    }
    elsif ( $time =~ /^\d\d:\d\d$/ ) {
        return $self->from_over24_time( $time . ":00" );
    }
    else {
        return $self->from_over24_datetime($time);
    }
}

sub from_over24_time {
    my ( $self, $time ) = @_;
    my $datetime = sprintf("%s %s",$self->ymd,$time);
    return $self->_from_over24($datetime);
}

sub from_over24_datetime {
    my ( $self, $datetime ) = @_;
    return $self->_from_over24($datetime);
}

sub over24_offset {
    my ( $self, $offset ) = @_;

    if ($offset) {
        #just hour
        if ( $offset =~ /^\d\d?$/ ) {
            $offset = sprintf( "%02d:00:00", $offset );
        }
        #hour:min
        elsif ( $offset =~ /^\d\d?:\d\d$/ ) {
            $offset .= ":00";
        }
        $OVER24_OFFSET = $offset;
        my $offset_sec = $self->_offset_sec();
        if ($offset_sec < 0 || ONE_DAY <= $offset_sec) {
          croak "out of offset range";
        }
    }
    return $OVER24_OFFSET;
}

sub is_during {
    my $self       = shift;
    my $start_time = shift || die "need start_time";
    my $end_time   = shift || die "need end_time";
    my $check_time = shift || $self;

    unless ( ( ref($start_time) eq "Time::Piece" ) ==
        ( ref($end_time) eq "Time::Piece" ) )
    {
        die "start_time and end_time is different object";
    }

    unless ( length($start_time) == length($end_time) ) {
        die "start_time and end_time is different format";
    }

    unless ( ref($check_time) eq "Time::Piece" ) {
        $check_time = $self->over24($check_time);
    }

    my ( $start_t, $end_t );
    if ( ref($start_time) eq "Time::Piece" ) {
        $start_t = $start_time;
        $end_t   = $end_time;
    }
    else {
      # to time_piece
        $start_t = $self->from_over24($start_time);
        $end_t   = $self->from_over24($end_time);
    }

    my $rtn = ( ( $start_t <= $check_time ) && ( $check_time <= $end_t ) )
      ? '1'
      : undef;
    return $rtn;
}

sub _over24_offset_object {
    my ($self) = @_;

    my $ymd =
      $self->over24_offset eq "00:00:00" ? $OVER24_BASETIME->ymd : $self->ymd;
    return $self->strptime( sprintf( "%s %s", $ymd, $self->over24_offset ),
        '%Y-%m-%d %T' );
}

sub _over24_offset_pattern {
  my ($self) = @_;

  my $offset_sec = $self->_offset_sec();
  my @hms = split /:/, $self->hms;
  my $sec = $self->_hms_to_sec(\@hms);
#  my $offset_day_sec = ONE_DAY * (int($offset_sec / ONE_DAY));
  if (0 < $offset_sec && $sec < $offset_sec) {
    #in offset
     $self -= ONE_DAY;
     $sec = $sec + ONE_DAY;
  }
  my $hour = int($sec / ONE_HOUR);
  return ( $self, $hour );
}

# done test
sub _from_over24 {
  my ( $self, $datetime ) = @_;

  my @hms = split /[\s:]/, $datetime;
  #date str:2015-10-04
  #hms array:(23,44,18)
  my $date = shift @hms;

  #sec
  my ($day,$hms) = $self->_hms_to_day_and_24_hours_less(\@hms);

  say $day;
  say $hms;

  #date
  say sprintf( "%s %s", $date, $hms );
  say $self->isdst;
  my $base = dclone $self;
  $base = $base->strptime( $date, "%Y-%m-%d" );
  say p $base;
  say p $self;
  say $base->isdst . "まえ";
  $base = $base;
  say $base->isdst ."あと";
  say $base;
  say $hms;
  my $test = $base->strptime( $base->date ." ". $hms, "%Y-%m-%d %T" );
  say $test->isdst;
  say $test ."テスト";
  say $test->epoch;
  my $t2 = $self->strptime($test->epoch,"%s");
  return $t2;
}

# オフセットを秒で返す。
sub _offset_sec {
  my $self = shift;
  my $offset = $self->over24_offset();

  my @hms = split /:/, $offset;
  return $self->_hms_to_sec(\@hms);
}

# done test
sub _hms_to_sec {
  my ($self,$hms) = @_;
  return $hms->[0] * ONE_HOUR + $hms->[1] * ONE_MINUTE + $hms->[2]; 
}

# hmsから日数を出す、それ以下はtime pieceのパースをさせる
# 1時をぱーすすると2時になる
# 2時をパースすると2時になるを実現するには時間分の秒数を足し込むでは吸収できない
# だので時間部分はTime::Piece側で吸収してもらう。
sub _hms_to_day_and_24_hours_less {
  my ($self,$hms) = @_;
  my $day = int ($hms->[0] / 24);
  my $hour = $hms->[0] % 24;
  return $day,sprintf('%02d:%02d:%02d',$hour,$hms->[1],$hms->[2]);
}

1;

__END__

=head1 NAME

Time::Piece::Over24 - Adds over 24:00:00 methods to Time::Piece

=head1 SYNOPSIS

  use Time::Piece::Over24;

  my $t = localtime;

  #e.g. 2011-01-01 04:00:00 now
  $t->over24_offset("05:00:00");

  #method changed!! time >>> datetime
  print $t->over24_datetime;
  >2010-12-31 28:00:00

  print $t->over24_time;
  >28:00:00

  print $t->over24_year;
  >2010

  print $t->over24_mon;
  >12

  print $t->over24_mday;
  >31

  print $t->over24_hour;
  >28;

  #e.g. today is 2011-01-01
  #retun Time::Piece object
  my $over_time = $t->from_over24_time("26:00:00");
  my $over_datetime = $t->from_over24_datetime("2011-01-01 26:00:00");

  print $over_time->datetime;
  print $over_datetime->datetime;
  >2011-01-02 02:00:00
  
  #over24 is alias over24_time and from_over24_time and from_over24_datetime
  $t->over24(); #call over24_time;
  $t->over24("26:00:00"); #call from_over24_time
  $t->over24("2011-01-01 26:00:00"); #call from_over24_datetime

  print $t->is_during("2010-12-31 23:00:00","2011-01-01 10:00:00");
  >1

  print $t->is_during("2011-01-01 05:00:00","2011-01-01 10:00:00");
  >Use of uninitialized value in print ...   = retrun value is undef!

=head1 METHODS

=over 4

=item over24_offset

start hour a day.

default "00:00:00".

value is undef, return offset time.

print localtime->over24_offset();

>00:00:00

not undef is set offset time.

value format is "5" or "05" or "05:00" or "05:00:00", every format is ok.

but set value range is [00:00:00 - 23:59:59]

e.g. over24_offset("05:00:00"); #hour range is [05:00:00 - 28:59:59]

e.g. over24_offset("11:00:00"); #hour range is [11:00:00 - 34:59:59]

=item over24_time

get datetime in offset time

=item from_over24_time, from_voer24_datetime

return a Time::Piece object. 

*not null over24_time e.g.over24_time("26:00:00") is alias, from_over24_time

*not null over24_datetime e.g.over24_datetime("26:00:00") is alias, from_over24_datetime

=item is_during

return 1 or undef

check a time

is_during("start_time","end_time","check_time");

check_time is option.default is now.

start_time and end_time format is datetime,time and timepiece object.

plz start and end is same format.

=back

=head1 AUTHOR

Synsuke Fujishiro <i47.rozary at gmail.com>

=head1 COPYRIGHT & LICENSE

(c) 2011, Synsuke Fujishiro.All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Time::Piece>, L<Time::Piece::MySQL>

=cut
