#!/usr/bin/perl -w

use Getopt::Long;
#use Text::Glob qw( match_glob glob_to_regex ); #my $regex=glob_to_regex("foo.*");

package dcl;
	$VERSION="0.1";
	$VERBOSE=0;
	$EJECT=0;
	$UMOUNT=0;
	$OVERRIDE=0;
	$FILELIST="";
	$NOREC=0;
	$PRETEND=0;
    $SHOW=0;
    $ASK=0;
    $FILTER="";
    $LANG="regex";
package main;

@rm_files=(".DS_Store","._.DS_Store",".Spotlight-V100","prova.dcl",'\.o$');
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
    my @rm_files=shift @_;
	opendir(DIR,$dir) or die $!;
	my @files=grep { !/^\.{1,2}$/ } readdir(DIR);
	closedir(DIR);
    if(!$dcl::NOREC){
       @dirs=grep { -d $_ } map{$dir . '/' . $_ } @files;
       print "subdir founded: @dirs\n";
       foreach $subdir (@dirs){
            p_verbose("dir founded: $subdir\n");
            clean ($subdir,$dcl::VERBOSE,@rm_files);
       }
    }
    p_verbose("in dir: $dir ...\n");
	foreach $file (@files) {
		p_verbose(":: $file");
        p_verbose("/") if (-d "$dir/$file");
		if(grep {$file =~ /$_/} @rm_files){
			p_verbose "	<<<<";
		}
		p_verbose("\n");
	}
}

sub main {
	my $dir='.';
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
                'lang|l=s' => \$dcl::LANG
			) or die ("Error in command line arguments");
	$dir=shift @ARGV || die("ARGV error. dir-path missing.");
    $dcl::SHOW=0 if($dcl::VERBOSE);  #show is a subset of verbose.
	p_verbose("dir-path: $dir\n");
	clean $dir,$dcl::VERBOSE,@rm_files;

}

main;

