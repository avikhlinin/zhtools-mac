#!/usr/bin/perl

# Setup
$TMP="/tmp";

# make sure we have minimum arg count
if ( $#ARGV < 5 ) {
  die "Usage: $0 [xpa] [filename] [save] [disp] [cmd] [cmd-specific-args]\n";
}

# we use standard argument lists, so disable the user's readpar file
delete ($ENV{'MY_READPAR_FILE'});

# process standard arguments
($XPA,$IFILENAME,$OFILE,$DISP,$CMD,@ARGS) = @ARGV;

# init variables
$IFILE="-";
$TMPFILE="$TMP/zhtools_$$.tmp1";
$TMPFILE2="$TMP/zhtools_$$.tmp2";

# top-level install directory
$ZHTOP="/soft/zhtools";
# but use ZHTOOLS environment variable if it exists
if ( $ENV{'ZHTOOLS'} ) {
  $ZHTOP = $ENV{'ZHTOOLS'};
}

# derived bin and help directories
$ZHBIN="$ZHTOP/bin";
$ZHHLP="$ZHTOP/zhhelp";

# make sure ZHTOOLS are available
if ( ! -x "$ZHBIN/zhhelp" ) {
 die "ERROR: cannot locate ZHTOOLS -- please remedy and try again\n";
}

# process output file directive (might not want to save it)
if ( $OFILE eq "none" ) {
  $OFILE="$TMP/zh_${CMD}_$$.fits";
#  name of the file with no path and no filter extension
  $OROOT = $IFILENAME;
  $OROOT =~ s!.*/!!s;  $OROOT =~ s/\[.*//s;
  $OFILENAME = "${OROOT}_$CMD";
  $SAVE=0;
} else {
  $OFILENAME=$OFILE;
  $SAVE=1;
}

# process commands

if ($CMD eq "zhhelp")
  { system ("$ZHBIN/zhhelp","-s",@ARGS) && die; exit 0; }
elsif ( $CMD eq "adapt" )  {
   if ( $#ARGS != 1) { die "ERROR: adapt [ncnt] [rmax]\n";  }
   ($ncnt,$rmax) = @ARGS;
   @pars=();
   push @pars,"ncnt=$ncnt";
   if ( $rmax !=0 ) {push @pars,"rsmomax=$rmax";}

   system ("echo","$ZHBIN/adapt",$IFILE,"out=$OFILE",@pars) && die;
   system ("$ZHBIN/adapt",$IFILE,"out=$OFILE",@pars,"quiet=yes") && die;

   &show_results;
   &cleanup;
   exit 0;
  }
elsif ($CMD eq "atrous" ) {
   if ( $#ARGS != 3 ) { die "ERROR: atrous [scale] [bkgd] [exp] [smooth]\n"; }

   @pars = ();
   ($scale,$bkgd,$exp,$smooth) = @ARGS;
   push @pars,"scale=$scale";
   if ( $bkgd ne "none" ) { push @pars,"scale=$scale"; }
   if ( $exp  ne "none" ) { push @pars,"exp=$exp"; }
   if ( $smooth == 1    ) { push @pars,"smooth=yes"; }

   system ("$ZHBIN/atrous",$IFILE,"out=$OFILE",@pars) && die;

   &show_results;
   &cleanup;
   exit 0;
  }
elsif ($CMD eq "mexhat" )  {
   if ( $#ARGS != 3 ) { die "ERROR: mexhat scale image [bkgd] [exp] [smooth]\n"; }

   @pars = ();
   ($scale,$bkgd,$exp,$snr) = @ARGS;
   if ( $bkgd ne "none" ) { push @pars,"scale=$scale"; }
   if ( $exp  ne "none" ) { push @pars,"exp=$exp"; }
   if ( $snr == 1    ) { push @pars,"snr=yes"; }

   system ("$ZHBIN/mexhat",$scale, $IFILE,"out=$OFILE",@pars) && die;

   &show_results;
   &cleanup;
   exit 0;
  }
elsif ($CMD eq "imexam") {
   if ( $#ARGS != 12 ) {
     die "ERROR: prbyreg imexam [sum] [mean] [errmean] [dispersion] [stddev] [absdev] [square] [sumsquare] [min] [max] [meancoords] [median]\n";
   }

   ($prbyreg,@modeflag) = @ARGS;

   if ( $prbyreg ) {
     $PRBYREG="yes";
   } else {
     $PRBYREG="no";
   }

   @MODE = ("sum","mean","errmean","dispersion","stddev","absdev","square","sumsquare","min","max",
	    "meancoords","median");
   $mode = 0;

   foreach $i ( 0 .. $#MODE ) {
     if ( $modeflag[$i] ) {
       if ( $mode ) {
	 $mode = "$mode,$MODE[$i]";
       } else {
	 $mode = "$MODE[$i]";
       }
     }
   }

   if ( ! $mode ) {
     die "please specify at least one imexam mode\n";
   }

   $TMPREG="$TMP/ds9$$.reg";
   $regnum = 0;
   open (R,"xpaget $XPA regions -coord image -format saoimage |") || die;
   open (OR,"> $TMPREG") || die;
   @regs = ();
   while (<R>) {
     chomp;

     if (/^\s*#/) {
       next;
     }

     if ( /^-/ ) {
       $ireg = 0;
     } else {
       $regnum ++;
       if ( ! $prbyreg ) {
	 $ireg = 0;
       } else {
	 $ireg = $regnum;
	 push @regs,$_;
       }
     }

     print OR $_;
     if ( $ireg ) {
       print OR " ",$ireg;
     }
     print OR "\n";
   }

   close(R);
   close(OR);

   if ( $regnum < 1 && $prbyreg ) {
     print STDERR "ERROR: please specify at least one 'include' region\n";
     unlink $TMPREG;
     exit 1;
   }

   if ( $regnum >= 1 ) {
     open (I,"$ZHBIN/imexam $IFILE $mode reg=$TMPREG printbyreg=$PRBYREG |") || die;
   } else {
     open (I,"$ZHBIN/imexam $IFILE $mode |") || die;
   }
   print "\n\n";
   if ($prbyreg) {
     print "#\t";
   }
   print join("\t",split(',',$mode)); print "\n";
   while (<I>) {
     chomp;
     print join("\t",split);
     if ($prbyreg) {
       ($i) = split;
       $i --;
       print "\t",@regs[$i];
     }
     print "\n";
   }
   close (I);

   unlink $TMPREG;
  }
elsif ($CMD eq "imsmo" )  {
   if ( $#ARGS != 1 ) { die "ERROR: imsmo [sigma] [exact]\n"; }

   ($sigma,$exact) = @ARGS;

   @pars=("sigma=$sigma");
   if ($exact) { push @pars,"exact=yes" }

   system ("$ZHBIN/imsmo","o=$OFILE",@pars,$IFILE) && die;

   &show_results;
   &cleanup;
   exit 0;
  }
elsif ($CMD eq "refinepos" ) {
   if ( $#ARGS != 2 ) { die "ERROR: refinepos [regions] [niter] [rsrc]\n";}

   ($regions,$niter,$rsrc)=@ARGS;

   open (R,"> $TMPFILE") || die;
   $regions =~ s/image;//g;
   @regs = split (';',$regions);
   $nreg = 0;
   foreach $reg ( @regs ) {
     $_=$reg;
     s/[\(\),]/ /g;
     ($type,$x,$y,$r)=split;
     if (!($type=~/^circle/)){$r=""};
     if(!($type=~/^polygon/i ||$type=~/^pie/i)) {
       $nreg ++;
       print R $x," ",$y," ",$r,"\n";
     }
   }
   close (R);
   if ( $nreg < 1) {
     unlink ($TMPFILE);
     die "ERROR: Refinepos requires at least one (circular) region\n";
   }

   open (R,"$ZHBIN/refinepos  img=$IFILE iter=$niter rsrc=$rsrc i=$TMPFILE |") || die "refinepos: $!\n";
   open (OR,"> $OFILE") || die "$OFILE: $!\n";
   while (<R>) {
     chomp;
     printf OR "image;circle(%s,%s,%s)\n",split;
   }
   close (R);
   close (OR);

   unlink ($TMPFILE);

   if ( ! $DISP ) {
     print "final region(s):\n";
     system ("cat $OFILE");
   } else {
     system ("xpaset -p $XPA regions deleteall") && die;
     system ("xpaset $XPA regions < $OFILE") && die;
   }

   if ( $SAVE ) {
     print "Saved refined regions file: $OFILE\n";
   } else {
     unlink ($OFILE);
   }
  }
else
  {
    die "ERROR: unknown zhtools function: $CMD\n";
  }


exit 0;

sub show_results {
  if ( $DISP ) {
    system ("xpaset","-p",$XPA,"frame","new") && die;
    system ("xpaset $XPA fits $OFILENAME < $OFILE") && die;
  }
}

sub cleanup {
  if ( $SAVE ) {
    print "Saved output FITS file: $OFILE\n";
  } else {
    unlink ($OFILE);
  }
}
