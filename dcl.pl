#!/usr/bin/perl

#dcl  D-cleaner (Disk && Directory Cleaner)
#author: Fernando Iazeolla
#licence: GPLv2

use warnings;
use Getopt::Long;
use strict;
#use Text::Glob qw( match_glob glob_to_regex ); #my $regex=glob_to_regex("foo.*");
# noooo, don't want to install external modules !!! i will hard code what i need !!!

%::languages=(regex=>"regex",glob=>"glob");
package dcl;
	$dcl::VERSION="0.1";
	$dcl::VERBOSE=0;
	$dcl::EJECT=0;
	$dcl::UMOUNT=0;
	$dcl::OVERRIDE=0;
	$dcl::FILELIST=undef;
	$dcl::NOREC=0;
	$dcl::PRETEND=0;
	$dcl::SHOW=0;
	$dcl::ASK=0;
	$dcl::FILTER=undef;
	$dcl::LANG=$main::languages{glob};
	$dcl::QUIET=0;
package main;

#@rm_files=(".DS_Store","._.DS_Store",".Spotlight-V100","foobar.dcl",'\.o$'); ##EXAMPLE
@::rm_files=(".DS_Store","._.DS_Store",".Spotlight-V100");
@::config_file_list=("/etc/dclrc","~/.dclrc");

sub show_version{
	print "dcl v$dcl::VERSION\n";
}
sub show_usage{
	show_version;
	print <<EOF;
by Fernando Iazeolla, iazasoft, 2013 (c)
this software is distributed under GPLv2 licence.

USAGE: dcl [ OPTIONS ] dir-path

where dir-path is the directory path
and OPTIONS are:
--help		-h		#show this help
--help config	-h config	#show help about .dclrc config file(s)
--version	-v		#show program version
--eject		-e		#eject volume after cleaned
--umount	-u		#unmount volume after cleaned.
--override	-o		#exclude the default built-in file list
--filelist <file>  -f <file>	#specify a custom file list
--norec		-r		#not recursive across sub dirs
--verbose	-vv		#verbose output
--show		-s		#show matching files to be deleted
--pretend	-p		#do not perform deletion.
--ask		-i [-a]		#ask confirmation before deleting each
--filter 'filter'  -x 'filter'	#define filter to be deleted on command line. 
--lang [regex|glob] -l [regex|glob] #set parser language. (Default=glob)
--quiet		-q		#quiet output.
EOF

	exit(1);
}
sub show_config_usage{
	print <<EOF;
you can customize the file list to be deleted by editing config files 
[/etc/dclrc , ~/.dclrc] 
or a custom file using the -f option. 
default built-in filter list is always read unless you use the --override option.
the default built in list actually is  
[".DS_Store","._.DS_Store",".Spotlight-V100"]  


dcl.rc example:
	
	%lang:glob 	#use glob syntax instead of regex
	*.o		#all object files (glob syntax)
	.DS_Dtore	#osx stuff !!
	Makefile.in
	#this is a comment

EOF
	exit(1);
}
sub opt_version_handler{
	show_version;
	exit(1);
}
sub opt_help_handler{
	my ($opt_name,$opt_value)=@_;
	if($opt_value eq "config")
	{
		show_config_usage;
		
	}
	else
	{
		show_usage;
	}
}
sub lang_filter{
	my @filter_list=@_;
	my @filtered_list=();
	return @filter_list if($dcl::LANG ne $::languages{glob});
	foreach my $filter_item (@filter_list){
		my $regex=undef;
		foreach my $letter (split(//,$filter_item)){
			if($letter eq "*")
			{
				$regex .="[^/]*";
			} elsif ($letter =~ /[\{\}\.\+\(\)\[\]]/) {
				$regex .= "\\$letter";
			} elsif ($letter eq "?") {
				$regex .= ".";
			} elsif ($letter eq '\\') {
				$regex .= "/";
			} else {
				$regex .= $letter;
			}
		}
		$regex="^$regex\$";
		push @filtered_list,$regex;
	}
	return @filtered_list;
}
sub read_config_file{
	my $cfg_file=shift @_;
	my @rm_files=();
	my @xx=glob "$cfg_file";
	my $xfile=shift @xx;
	my $ll="";
	return @rm_files if( ! -e $xfile );
	print "CFG: $xfile\n" if($dcl::VERBOSE);
	open FD,"<$xfile" or return @rm_files;
	my @lines=<FD>;
	close FD;
	foreach $ll (@lines){
		next if($ll=~/^\#/);
		next if($ll=~/^\n/);
		$ll=~ s/#.*\n$//g;
		$ll=~ s/[\s\n\r\t]+//g;
		if($ll=~/^%lang:/){
			if($' eq $::languages{regex} || $' eq $::languages{glob}){
				$dcl::LANG=$';
			}
			else
			{
				warn("invalid parsing language declaration on config file. Using default.\n");
			}
			next;
		}
		push @rm_files,$ll;
		
	}
	return @rm_files;
}
sub p_verbose{
	return if(!$dcl::VERBOSE);
	print @_ ;
}
sub p_show{
	return if(!$dcl::SHOW);
	print @_ ;
}
sub clean{
	my $dir=shift @_;
	local $dcl::VERBOSE=shift @_;
	my @rm_files=@_;
	opendir(DIR,$dir) or die $!;
	my @files=grep { !/^\.{1,2}$/ } readdir(DIR);
	closedir(DIR);
	if(!$dcl::NOREC){
		my @dirs=grep { -d $_ } map{$dir . '/' . $_ } @files;
		foreach my $subdir (@dirs){
			clean ($subdir,$dcl::VERBOSE,@rm_files);
		}
	}
	my $str=">> in dir: $dir #with @rm_files\n";
	p_verbose($str);
	my $count=0;
	foreach my $file (@files) {
		p_verbose(":: $file");
		p_verbose("/") if (-d "$dir/$file");
		if(grep {$file =~ /$_/} @rm_files){
			p_verbose "	<<<< ";
			if(!$count){$count++;p_show(">> in dir: $dir\n");}
			p_show(":: $file");
			p_show("/") if (-d "$dir/$file");
			p_show(" \t<<<< ");
			#perform deletion
			if(!$dcl::PRETEND){
				if($dcl::ASK){
					print "remove ";
					if($dcl::VERBOSE || $dcl::SHOW)
					{
						print "it? ";
					}
					else
					{
						print "$file? ";
					}
					my $xx=lc <STDIN>;chomp $xx;
					next if($xx ne "y" && $xx ne "yes");
				}
				if(-d "$dir/$file"){
					p_show(" ...queued to delete.\n");
					p_verbose(" ...queued to delete.\n");
					clean("$dir/$file",0,'\.*');
					rmdir "$dir/$file";
					p_show("++ $file/	<<<<  deleted.");
					p_verbose("++ $file/	<<<<  deleted.");
				}
				else{
					unlink "$dir/$file";
					p_show(" deleted.");
					p_verbose(" deleted.");
				}
			}
			p_show("\n");
		}
		p_verbose("\n");
	}
}

sub main {
	my $dir='.';
	my $lang=undef;
	my @rm_filter=();
	GetOptions( 'help|h:s' => \&opt_help_handler,
		'version|v' => \&opt_version_handler,
		'verbose|vv' => \$dcl::VERBOSE,
		'show|s' => \$dcl::SHOW,
		'ask|a|i' => \$dcl::ASK,
		'pretend|p' => \$dcl::PRETEND,
		'override|O' => \$dcl::OVERRIDE,
		'norec|R' => \$dcl::NOREC,
		'eject|e' => \$dcl::EJECT,
		'umount|u' => \$dcl::UMOUNT,
		'filter|x=s' => \$dcl::FILTER,
		'filelist|f=s' => \$dcl::FILELIST,
		'lang|l=s' => \$lang,
		'quiet|q'=> \$dcl::QUIET
		) or die ("Error in command line arguments");
	$dir=shift @ARGV || die("ARGV error. dir-path missing.");
	$dcl::SHOW=0 if($dcl::VERBOSE);  #show is a subset of verbose.
	if($dcl::QUIET){$dcl::SHOW=0;$dcl::VERBOSE=0;}	#quiet wins !
	@rm_filter=@::rm_files if(!$dcl::OVERRIDE);
	foreach  (@::config_file_list) {
		push @rm_filter,lang_filter(read_config_file($_));
	}
	push @rm_filter,lang_filter(read_config_file($dcl::FILELIST)) if($dcl::FILELIST);
	if($lang){	#last word at command line !
		if($lang eq $::languages{regex} || $lang eq $::languages{glob}){
				$dcl::LANG=$lang;
		}
		else
		{
			warn("invalid language type. Using default.\n");
		}
	}
	if($dcl::FILTER){
		push @rm_filter,lang_filter(split /[ :,;]/,$dcl::FILTER) ;
	}
	p_verbose("dir-path: $dir\n");
	clean ($dir,$dcl::VERBOSE,@rm_filter);
	print"Ok.\n" unless $dcl::QUIET;
	if($dcl::EJECT || $dcl::UMOUNT){
		#print "umount && eject not yet coded... be patient :)\n" unless $dcl::QUIET;
		`umount "$dir"` ;
	}
	
}

main;

