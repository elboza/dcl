#!/usr/bin/perl -w

use Getopt::Long;

sub clean{
	my $dir='.';
	opendir(DIR,$dir) or die $!;
	my @files=readdir(DIR);
	closedir(DIR);
	foreach my $i (@files) {
		print ":: $i\n"
	}
}

sub main {
	my $len=23;
	GetOptions( 'length|l=i' => \$len) or die ("Error in command line arguments");
	print "$len\n";
	foreach my $i (@ARGV) {
		print "$i\n";
	}
	clean;

}

main;

