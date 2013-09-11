dcl
===

##D-cleaner [ Disk && Directory Cleaner ]

given a path **dcl** will clean this directory, and eventually subdirs, from a list of files, and eventually unmount or eject the volume. 
 
####config files
you can customize the file list to be deleted by editing config files   
`[/etc/dclrc , ~/.dclrc]`  
or a custom file using the `-f` option. 
default built-in filter list is always read unless you use the `--override` option.  
the default built in list actually is  
`[".DS_Store","._.DS_Store",".Spotlight-V100"]`  

####dcl.rc example:
	
	%lang:glob     #use glob syntax instead of regex
	*.o            #all object files (glob syntax)
	.DS_Dtore      #osx stuff !!
	Makefile.in
	#this is a comment

##install

```
sudo make install
```

or run it locally on yout directory.

###help

```
$ dcl -h
dcl v0.1
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

```
###examples

```
$ dcl -vv -p -r .       #show verbose without deleting(--pretend option) files that would be 
                        #deleted only in this dir  

$ dcl -s -u /mnt/Disk1      #clean /mnt/Disk1 recursively showing only deleted files 
                            #and unmount the volume.  

$ dcl /mnt/Disk2        #clean /mnt/Disk1 recursively. output almost nothing.(use -q for no output)


#these perform the same:
$ dcl -x '*.o *.c' /mnt/floppy	#clean all .c and all .o files from /mnt/floppy

$ dcl -x '*.o;*.c' /mnt/floppy  #clean all .c and all .o files from /mnt/floppy

$ dcl -x '*.o:*.c' /mnt/floppy  #clean all .c and all .o files from /mnt/floppy

$ dcl -x '*.o,*.c' /mnt/floppy  #clean all .c and all .o files from /mnt/floppy
```

#####web
[dcl project page](http://github.com/elboza/dcl)

####That's all falks!

```
 _____
< bye >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
