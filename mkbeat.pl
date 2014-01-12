#!/usr/bin/perl

use warnings;
use strict;

use File::Basename;

my %cfg = ( FIRST => 0, LAST => 1, SOURCE => "0,0", TARGET => "0,100", TIMETARGET => 2, MARK => '*', TARGETMARK => 'O' );
my @beats;
my $total = 0;

sub fmttime($) {
	my $time = sprintf "%.02f", shift;
	my ($sec,$frac) = $time =~ /^(\d+)(\..*)$/;
	my $min = int($sec/60);
	$sec -= $min*60;
	my $hr = int($min/60);
	$min -= $hr*60;
	return sprintf "%d:%02d:%02d%s", $hr,$min,$sec,$frac;
}

sub interp {
	my ($src,$dst,$frac,$dur) = @_;
	my ($sx,$sy) = split /,/, $src;
	my ($dx,$dy) = split /,/, $dst;
	return sprintf "%d,%d",
		($sx + ($dx - $sx) * $frac/$dur),
		($sy + ($dy - $sy) * $frac/$dur);
}

sub readbeats {
  @beats = ();
  $total = 0;

  my $f = shift;
  while (<$f>) {
	chomp;
	my $line = $_;
	s/\s*#.*$//;
	if (/^BREAK/) {
		return 1;
	} elsif (/^(\d+)@([\d.]+)\s*(\S*)$/) {
		push @beats, [$1, $2, $3];
		$total += $1 / $2;
	} elsif (/^(\w+)=(.+)$/) {
		$cfg{$1} = $2;
	} elsif (/^\s*$/) {
	} else {
		die "Can't parse line $.: $line\n";
	}
  }
  return $total;
}

my $patname = shift;

my ($basename,$path) = fileparse $patname, qr/\.[^.]+$/;
$basename = "$path/$basename";

open my $in, "<", $patname or die "Can't read $patname: $!\n";
while (readbeats $in) {

die "Need at least one beat!\n" unless $total > 0;

my $finish = $cfg{FINISH} || $cfg{TARGET};
my $timefinish = $cfg{TIMEFINISH} || 0;

my ($base,$bpm);

if ($cfg{BPM}) {
	$bpm = $cfg{BPM};
	$base = 60/$cfg{BPM};
} else {
	$cfg{MID} ||= $cfg{LAST};
	$cfg{MIDNUM} ||= $total;

	my $time = $cfg{MID}-$cfg{FIRST};
	$base = $time / ($cfg{MIDNUM} - 1);
	$bpm = 60 / $base;
}
my $time = $total * $base;
printf "$total full beats over $time sec, %.3f base beat time (%.1f BPM)\n", $base, $bpm;

my $hdrname = "$basename.header";
open my $hdr, "<", $hdrname or die "Can't read $hdrname: $!\n";

my $assname = "$basename.ass";
open my $ass, ">", $assname or die "Can't write $assname: $!\n";
print $ass $_ while <$hdr>;

printf $ass "Dialogue: 0,%s,%s,Target,,0,0,0,,{\\pos($cfg{TARGET})}$cfg{TARGETMARK}\n",
	fmttime $cfg{FIRST}, fmttime $cfg{FIRST}+$total*$base;

my $beat = 0;
for my $entry (@beats) {
	while ($entry->[0]-- > 0) {
		my $time = $cfg{FIRST} + $beat * $base;
		my $durtarget = $cfg{TIMETARGET};
		my $durfinish = $timefinish;
		my $src = $cfg{SOURCE};
		my $mark = $entry->[2] || $cfg{MARK};
		$mark = $beat if $mark eq '\\R';
		if ($time < $durtarget){
			$src = interp $src, $cfg{TARGET}, $durtarget-$time, $durtarget;
			$durtarget = $time;
		}

		printf $ass "Dialogue: 0,%s,%s,Beat%d,,0,0,0,,{\\move(%s,$finish)}%s\n",
			fmttime $time - $durtarget, fmttime $time + $durfinish,
			$entry->[1], $src, $mark;
		$beat += 1/$entry->[1];
	}
}

}
