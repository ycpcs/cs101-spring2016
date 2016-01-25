#! /usr/bin/perl

use strict;
use FileHandle;

sub Run {
	my ($cmd) = @_;
	system($cmd)/256 == 0 || die "Couldn't execute $cmd\n";
}

my $fname = shift @ARGV || die;
($fname =~ m,^(CS101_.*)\.zip$,) || die;
my $labname = $1;

Run("unzip $fname");

my $makefile = `find $labname -name Makefile -print`;
chomp $makefile;

print "Makefile is $makefile\n";

print "Fixing $makefile...";
STDOUT->flush();

my $ifh = new FileHandle("<$makefile");
my $ofh = new FileHandle(">$makefile.tmp");

while (<$ifh>) {
	if (/^\s*PROJECT_NUMBER\s*:?=/) {
		print $ofh $_;
		print $ofh <<"EOF";
\r
# Some unknown software on the KEC Windows load\r
# sets the GCC_EXEC_PREFIX environment variable, which\r
# prevents Cygwin's gcc/g++ from working correctly.\r
# Make sure it is unset when we invoke g++.\r
CXX = unset GCC_EXEC_PREFIX && g++\r
EOF
	} elsif (/^\s*CXX\s+:?=/) {
		print "Warning: not echoing assignment to CXX macro in $makefile\n";
	} else {
		print $ofh $_;
	}
}
$ifh->close();
$ofh->close();
Run("mv $makefile.tmp $makefile");
print "done\n";

# If zipfile was generated with an extra level, fix it.
if ($makefile =~ m,^$labname/$labname,) {
	print "Fixing extra level in zipfile...";
	STDOUT->flush();

	Run("mv $labname x");
	Run("mv x/$labname .");
	Run("rmdir x");

	print "done\n";
}

print "Generating new zipfile...";
STDOUT->flush();

Run("rm -f $fname");
Run("zip -9r $fname $labname");
print "done\n";
