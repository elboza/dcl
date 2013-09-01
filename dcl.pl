#!/usr/bin/perl -w

use Getopt::Long;

package dcl;
	$VERSION="0.1";
	$VERBOSE=0;
	$EJECT=0;
	$UMOUNT=0;
	$OVERRIDE=0;
	$FILELIST="";
	$NOREC=0;
	$PRETEND=0;
package main;

@rm_files=(".DS_Store","._.DS_Store",".Spotlight-V100","prova.dcl",'\.o$');
sub show_version{
	print "dcl v$dcl::VERSION\n";
}
sub show_usage{
	show_version;
	print <<EOF;
by Fernando Iazeolla, iazasoft, 2013 ©
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
--show		-s		#same as --verbose
--pretend	-p		#do not perform deletion. 

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
	if($opt_value =~ /config/)
	{
		show_config_usage;
		
	}
	else
	{
		show_usage;
	}
}
sub p_verbose{
	return if($dcl::VERBOSE==0);
	print @_ ;
}

sub clean{
	my $dir=shift @_;
	opendir(DIR,$dir) or die $!;
	my @files=readdir(DIR);
	closedir(DIR);
	foreach $file (@files) {
		p_verbose(":: $file");
		if(grep {$file =~ /$_/} @rm_files){
			p_verbose "	<<<<";
		}
		p_verbose("\n");
	}
}

sub main {
	my $dir='.';
	my $len=23;
	GetOptions( 'help|h:s' => \&opt_help_handler,
				'version|v' => \&opt_version_handler,
				'verbose|show|vv|s' => \$dcl::VERBOSE
			) or die ("Error in command line arguments");
	$dir=shift @ARGV || die("dir-path missing.");
	p_verbose("dir-path: $dir\n");
	clean $dir;

}

main;

