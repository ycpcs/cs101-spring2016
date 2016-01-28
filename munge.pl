#! /usr/bin/perl

sub Xlate {
	my ($pnum) = @_;
	return $pnum + 133;
}

while (<>) {
	s,p=(\d+),"p=".Xlate($1),ge;
	print;
}
