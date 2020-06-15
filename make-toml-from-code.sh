#!/usr/bin/perl
use strict;
use warnings;

opendir (DIR, 'raw-codes') or die "Unable to open raw-codes/";

print "[[protocols]]
name = 'lg-ac-remote'
protocol = 'raw'
";

while(my $file = readdir(DIR)){
	next if ($file eq '.' || $file eq '..');
	open FILE, "raw-codes/$file" or die $!;
	my @ps = ();
        my $dir = "+";
	while(<FILE>){
		foreach my $l (split /[ \n]/) {
			if ($l ne "") {
				push @ps, "$dir$l";
				$dir = $dir eq "+" ? "-" : "+";
			}
		}
	}	
	print "[[protocols.raw]]\nkeycode = '$file'\nraw = '" . join(' ', @ps) . "'\n";
}
close(DIR);
