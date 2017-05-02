#!/usr/bin/perl
use strict;
use warnings;

my @temp = 18..30;
my @fan=qw/low med high cycle/;
$SIG{INT}='ignore';

foreach my $f (@fan){
	print "--- Set fan to $f ---\n";
	foreach my $t (@temp){
		print "=== Temp $t ===\n";
		
		print `mode2 -m -d /dev/lirc0 | tee "/root/lg/on-$t-$f"`;
		
		#cleanup the first int from the file.
		print `sed -i '1d' "/root/lg/on-$t-$f"`;
	}
}
