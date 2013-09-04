#!/usr/bin/perl -w

use Getopt::Long;
use strict;
#use Text::Glob qw( match_glob glob_to_regex ); #my $regex=glob_to_regex("foo.*");
# noooo, don't want to install external modules !!! i will hard code what i need !!!

package dcl;
	$dcl::VERSION="0.1";
	$dcl::VERBOSE=0;
	$dcl::EJECT=0;
	$dcl::UMOUNT=0;
	$dcl::OVERRIDE=0;
	$dcl::FILELIST="";
	$dcl::NOREC=0;
	$dcl::PRETEND=0;
	$dcl::SHOW=0;
	$dcl::ASK=0;
	$dcl::FILTER="";
	$dcl::LANG="regex";
package main;

#@rm_files=(".DS_Store","._.DS_Store",".Spotlight-V100","foobar.dcl",'\.o$'); ##EXAMPLE
@::rm_files=(".DS_Store","._.DS_Store",".Spotlight-V100");
#@::languages=("regex","glob");
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
--override	-O		#exclude the default built-in file list
--filelist	-f		#specity a custom file list
--norec		-R		#not recursive thru sub dirs
--verbose	-vv		#verbose output
--show		-s		#show matching files to be deleted
--pretend	-p		#do not perform deletion.
--ask		-i [-a]	#ask confirmation before deleting each
--filter	-x		#define files filter to be deleted on command line. 
--lang [regex|glob] -l [regex|glob] #set parser language.
EOF

	exit(1);
}
sub show_config_usage{
	print <<EOF;
you can customize the file list to be deleted by editing config files [/etc/dclrc , ~/.dclrc] or a custom file using the -f option. default built-in file list is always read unless you use the --override option.

dcl.rc example:
	*.o		#all object files
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
	#print ",,$opt_name,, ;;$opt_value;;\n";
	if($opt_value eq "config")
	{
		show_config_usage;
		
	}
	else
	{
		show_usage;
	}
}
sub read_config_file{
	my $cfg_file=shift @_;
	my @rm_files=();
	my @xx=glob "$cfg_file";
	my $xfile=shift @xx;
	my $ll="";
	#print "-- $cfg_file\n";
	return @rm_files if( ! -e $xfile );
	print "CFG: $xfile\n" if($dcl::VERBOSE);
	open FD,"<$xfile" or return @rm_files;
	my @lines=<FD>;
	close FD;
	#print @lines; # -----------
	foreach $ll (@lines){
		next if($ll=~/^\#/);
		next if($ll=~/^\n/);
		$ll=~ s/#.*\n$//g;
		$ll=~ s/[\s\n\r\t]+//g;
		if($ll=~/^%lang:/){
			if($' eq "regex" || $' eq "glob"){
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
	#print @rm_files;
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
					clean("$dir/$file",0,'\.*');
					rmdir "$dir/$file";
				}
				else{
					unlink "$dir/$file";
				}
				p_show(" deleted.");
				p_verbose(" deleted.");
			}
			p_show("\n");
		}
		p_verbose("\n");
	}
}

sub main {
	my $dir='.';
	my $lang="";
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
                'lang|l=s' => \$lang
			) or die ("Error in command line arguments");
	$dir=shift @ARGV || die("ARGV error. dir-path missing.");
	$dcl::SHOW=0 if($dcl::VERBOSE);  #show is a subset of verbose.
	@rm_filter=@::rm_files if(!$dcl::OVERRIDE);
	foreach  (@::config_file_list) {
		push @rm_filter,read_config_file($_);
	}
	if($lang ne ""){	#last word at command line !
		if($lang eq "regex" || $lang eq "glob"){
				$dcl::LANG=$lang;
		}
		else
		{
			warn("invalid language type. Using default.\n");
		}
	}
	if($dcl::FILTER ne ""){
		push @::rm_files,split /[ :,;]/,$dcl::FILTER ;
	}
	p_verbose("dir-path: $dir\n");
	#p_show("with filter: @::rm_files\n");
	clean ($dir,$dcl::VERBOSE,@rm_filter);

}

main;

