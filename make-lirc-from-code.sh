#!/usr/bin/perl
use strict;
use warnings;

opendir (DIR, 'raw-codes') or die "Unable to open raw-codes/";

print 'begin remote

  name  lg.conf
  flags RAW_CODES
  eps            30
  aeps          100

  gap          16777215

      begin raw_codes
';

while(my $file = readdir(DIR)){
	next if ($file eq '.' || $file eq '..');
	open FILE, "raw-codes/$file" or die $!;
	print "	name $file\n";
	while(<FILE>){
		print $_;
	}	
	print "\n";
}
print "	end raw_codes

end remote";
close(DIR);
