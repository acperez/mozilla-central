#!/usr/bin/perl

require 5.000;

use Sys::Hostname;
use POSIX "sys_wait_h";
use Cwd;

$Version = '$Revision: 1.24 $ ';


sub PrintUsage {
  die <<END_USAGE
usage: $0 [options]
Options:
  --depend               Build depend (must have this option or clobber).
  --clobber              Build clobber.
  --once                 Do not loop.
  --compress             Use '-z3' for cvs.
  --example-config       Print an example 'tinderconfig.pl'.
  --noreport             Do not report status to tinderbox server.
  --notest               Do not run smoke tests.
  --timestamp            Pull by date.
   -tag TREETAG          Pull by tag (-r TREETAG).
   -t TREENAME           The name of the tree
  --mozconfig FILENAME   Provide a mozconfig file for client.mk to use.
  --version              Print the version number (same as cvs revision).
  --testonly             Only run the smoke tests (do not pull or build).
  --help
More details:
  To get started, run '$0 --example-config'.
END_USAGE
}

&InitVars;
&ParseArgs;
&ConditionalArgs;
&GetSystemInfo;
&LoadConfig;
&SetupEnv;
&SetupPath;
&BuildIt;

1;

# End of main
# ------------------------------------------------------

sub ParseArgs {
  
  &PrintUsage if $#ARGV == -1;

  while ($arg = shift @ARGV) {
    $BuildDepend = 0   , next if $arg eq '--clobber';
    $BuildDepend = 1   , next if $arg eq '--depend';
    $CVS = 'cvs -q -z3', next if $arg eq '--compress';
    &PrintExampleConfig, exit if $arg eq '--example-config';
    &PrintUsage        , exit if $arg eq '--help' or $arg eq '-h';
    $ReportStatus = 0  , next if $arg eq '--noreport';
    $RunTest = 0       , next if $arg eq '--notest';
    $BuildOnce = 1     , next if $arg eq '--once';
    $UseTimeStamp = 1  , next if $arg eq '--timestamp';
    $TestOnly = 1      , next if $arg eq '--testonly';

    if ($arg eq '-tag') {
      $BuildTag = shift @ARGV;
      &PrintUsage if $BuildTag eq '' or $BuildTag eq '-t';
    }
    elsif ($arg eq '-t') {
      $BuildTree = shift @ARGV;
      &PrintUsage if $BuildTree eq '';
    }
    elsif ($arg eq '--mozconfig' or $arg eq '--configfile') {
	  # File generated by the build configurator,
      #   http://cvs-mirror.mozilla.org/webtools/build/config.cgi
      $MozConfigFileName = shift @ARGV;
      &PrintUsage if $MozConfigFileName eq '';
    }
    elsif ($arg eq '--version' or $arg eq '-v') {
      die "$0: version" . substr($Version,9,6) . "\n";
    } else {
      &PrintUsage;
    }
  }
  &PrintUsage if $BuildTree =~ /^\s+$/i;
}

sub InitVars {
  for (@ARGV) {
    # Save DATA section for printing the example.
    return if /^--example-config$/;
  }
  eval while <DATA>;  # See __END__ section below
}

sub PrintExampleConfig {
  print "#- tinder-config.pl - Tinderbox configuration file.\n";
  print "#-    Uncomment the variables you need to set.\n";
  print "#-    The default values are the same as the commented variables\n\n";
  
  while (<DATA>) {
    s/^\$/\#\$/;
    print;
  }
}

sub ConditionalArgs {
  $fe          = 'mozilla-bin';
  $RelBinaryName  = "dist/bin/$fe";
  #$FullBinaryName  = "$BaseDir/$DirName/$TopLevel/$Topsrcdir/$RelBinaryName";
  $BuildModule = 'SeaMonkeyAll';
  $CVSCO      .= " -r $BuildTag" unless $BuildTag eq '';
}

sub GetSystemInfo {
  $OS        = `uname -s`;
  $OSVer     = `uname -r`;
  $CPU       = `uname -m`;
  $BuildName = ''; 
  
  my $host   = hostname;
  $host =~ s/\..*$//;
  
  chomp($OS, $OSVer, $CPU, $host);

  if ($OS eq 'AIX') {
    my $osAltVer = `uname -v`;
    chomp($osAltVer);
    $OSVer = "$osAltVer.$OSVer";
  }
  
  $OS = 'BSD_OS' if $OS eq 'BSD/OS';
  $OS = 'IRIX'   if $OS eq 'IRIX64';

  if ($OS eq 'QNX') {
    $OSVer = `uname -v`;
    chomp($OSVer);
    $OSVer =~ s/^([0-9])([0-9]*)$/$1.$2/;
  }
  if ($OS eq 'SCO_SV') {
    $OS = 'SCOOS';
    $OSVer = '5.0';
  }
  
  unless ("$host" eq '') {
    $BuildName = "$host $OS ". ($BuildDepend ? 'Depend' : 'Clobber');
  }
  $DirName = "${OS}_${OSVer}_". ($BuildDepend ? 'depend' : 'clobber');
  $logfile = "${DirName}.log";

  #
  # Make the build names reflect architecture/OS
  #
  
  if ($OS eq 'AIX') {
    # Assumes 4.2.1 for now.
  }
  if ($OS eq 'BSD_OS') {
    $BuildName = "$host BSD/OS $OSVer ". ($BuildDepend ? 'Depend' : 'Clobber');
  }
  if ($OS eq 'FreeBSD') {
    $BuildName = "$host $OS/$CPU $OSVer ". ($BuildDepend ? 'Depend':'Clobber');
  }
  if ($OS eq 'HP-UX') {
  }
  if ($OS eq 'IRIX') {
  }
  if ($OS eq 'Linux') {
    if ($CPU eq 'alpha' or $CPU eq 'sparc') {
      $BuildName = "$host  $OS/$CPU $OSVer "
                 . ($BuildDepend ? 'Depend' : 'Clobber');
    } elsif ($CPU eq 'armv4l' or $CPU eq 'sa110') {
      $BuildName = "$host $OS/arm $OSVer ". ($BuildDepend?'Depend':'Clobber');
    } elsif ($CPU eq 'ppc') {
      $BuildName = "$host $OS/$CPU $OSVer ". ($BuildDepend?'Depend':'Clobber');
    } else {
      $BuildName = "$host $OS ". ($BuildDepend?'Depend':'Clobber');

      # What's the right way to test for this?
      $ObjDir .= 'libc1' if $host eq 'truth';
    }
  }
  if ($OS eq 'NetBSD') {
    $BuildName = "$host $OS/$CPU $OSVer ". ($BuildDepend?'Depend':'Clobber');
  }
  if ($OS eq 'OSF1') {
    # Assumes 4.0D for now.
  }
  if ($OS eq 'QNX') {
  }
  if ($OS eq 'SunOS') {
    if ($CPU eq 'i86pc') {
      $BuildName = "$host $OS/i386 $OSVer ". ($BuildDepend?'Depend':'Clobber');
    } else {
      $OSVerMajor = substr($OSVer, 0, 1);
      if ($OSVerMajor ne '4') {
        $BuildName = "$host $OS/sparc $OSVer "
                   . ($BuildDepend?'Depend':'Clobber');
      }
    }
  }
}

sub SetupEnv {
  umask 0;
  #$ENV{CVSROOT} = ':pserver:anonymous@cvs-mirror.mozilla.org:/cvsroot';
  $ENV{LD_LIBRARY_PATH} = "$NSPRDir/lib:"
     ."$BaseDir/$DirName/mozilla/${ObjDir}dist/bin:/usr/lib/png:"
     ."/usr/local/lib:$BaseDir/$DirName/mozilla/dist/bin";
  $ENV{DISPLAY} = $DisplayServer;
  $ENV{MOZCONFIG} = "$BaseDir/$MozConfigFileName" if $MozConfigFileName ne '';
}

sub SetupPath {
  my $comptmp;
  $comptmp = '';
  #print "Path before: $ENV{PATH}\n";
  
  if ($OS eq 'AIX') {
    $ENV{PATH}        = "/builds/local/bin:$ENV{PATH}:/usr/lpp/xlC/bin";
    $ConfigureArgs   .= '--x-includes=/usr/include/X11 '
                      . '--x-libraries=/usr/lib --disable-shared';
    $ConfigureEnvArgs = 'CC=xlC_r CXX=xlC_r';
    $Compiler         = 'xlC_r';
    $NSPRArgs        .= 'NS_USE_NATIVE=1 USE_PTHREADS=1';
  }
  
  if ($OS eq 'BSD_OS') {
    $ENV{PATH}        = "/usr/contrib/bin:/bin:/usr/bin:$ENV{PATH}";
    $ConfigureArgs   .= '--disable-shared';
    $ConfigureEnvArgs = 'CC=shlicc2 CXX=shlicc2';
    $Compiler         = 'shlicc2';
    $mail             = '/usr/ucb/mail';
    # Because ld dies if it encounters -include
    $MakeOverrides    = 'CPP_PROG_LINK=0 CCF=shlicc2';
    $NSPRArgs        .= 'NS_USE_GCC=1 NS_USE_NATIVE=';
  }

  if ($OS eq 'FreeBSD') {
    $ENV{PATH}        = "/bin:/usr/bin:$ENV{PATH}";
    if ($ENV{HOST} eq 'angelus.mcom.com') {
      $ConfigureEnvArgs = 'CC=egcc CXX=eg++';
      $Compiler       = 'egcc';
    }
    $mail             = '/usr/bin/mail';
  }

  if ($OS eq 'HP-UX') {
    $ENV{PATH}        = "/opt/ansic/bin:/opt/aCC/bin:/builds/local/bin:"
                      . "$ENV{PATH}";
    $ENV{LPATH}       = "/usr/lib:$ENV{LD_LIBRARY_PATH}:/builds/local/lib";
    $ENV{SHLIB_PATH}  = $ENV{LPATH};
    $ConfigureArgs   .= '--x-includes=/usr/include/X11 '
                      . '--x-libraries=/usr/lib --disable-gtktest ';
    $ConfigureEnvArgs = 'CC="cc -Ae" CXX="aCC -ext"';
    $Compiler         = 'cc/aCC';
    # Use USE_PTHREADS=1 instead of CLASSIC_NSPR if you've got DCE installed.
    $NSPRArgs        .= 'NS_USE_NATIVE=1 CLASSIC_NSPR=1';
  }
  
  if ($OS eq 'IRIX') {
    $ENV{PATH}        = "/opt/bin:$ENV{PATH}";
    $ENV{LD_LIBRARY_PATH}   .= ':/opt/lib';
    $ENV{LD_LIBRARYN32_PATH} = $ENV{LD_LIBRARY_PATH};
    $ConfigureEnvArgs = 'CC=cc CXX=CC CFLAGS="-n32 -O" CXXFLAGS="-n32 -O"';
    $Compiler         = 'cc/CC';
    $NSPRArgs        .= 'NS_USE_NATIVE=1 USE_PTHREADS=1';
  }
  
  if ($OS eq 'NetBSD') {
    $ENV{PATH}        = "/bin:/usr/bin:$ENV{PATH}";
    $ENV{LD_LIBRARY_PATH} .= ':/usr/X11R6/lib';
    $ConfigureEnvArgs = 'CC=egcc CXX=eg++';
    $Compiler         = 'egcc';
    $mail             = '/usr/bin/mail';
  }
  
  if ($OS eq 'OSF1') {
    $ENV{PATH}        = "/usr/gnu/bin:$ENV{PATH}";
    $ENV{LD_LIBRARY_PATH} .= ':/usr/gnu/lib';
    $ConfigureEnvArgs = 'CC="cc -readonly_strings" CXX="cxx"';
    $Compiler         = 'cc/cxx';
    $MakeOverrides    = 'SHELL=/usr/bin/ksh';
    $NSPRArgs        .= 'NS_USE_NATIVE=1 USE_PTHREADS=1';
    $ShellOverride    = '/usr/bin/ksh';
  }
  
  if ($OS eq 'QNX') {
    $ENV{PATH}        = "/usr/local/bin:$ENV{PATH}";
    $ENV{LD_LIBRARY_PATH} .= ':/usr/X11/lib';
    $ConfigureArgs   .= '--x-includes=/usr/X11/include '
                      . '--x-libraries=/usr/X11/lib --disable-shared ';
    $ConfigureEnvArgs = 'CC="cc -DQNX" CXX="cc -DQNX"';
    $Compiler         = 'cc';
    $mail             = '/usr/bin/sendmail';
  }

  if ($OS eq 'SunOS') {
    if ($OSVerMajor eq '4') {
      $ENV{PATH}      = "/usr/gnu/bin:/usr/local/sun4/bin:/usr/bin:$ENV{PATH}";
      $ENV{LD_LIBRARY_PATH} = "/home/motif/usr/lib:$ENV{LD_LIBRARY_PATH}";
      $ConfigureArgs .= '--x-includes=/home/motif/usr/include/X11 '
                      . '--x-libraries=/home/motif/usr/lib';
      $ConfigureEnvArgs = 'CC="egcc -DSUNOS4" CXX="eg++ -DSUNOS4"';
      $Compiler       = 'egcc';
    } else {
      $ENV{PATH}      = '/usr/ccs/bin:' . $ENV{PATH};
    }
    if ($CPU eq 'i86pc') {
      $ENV{PATH}      = '/opt/gnu/bin:' . $ENV{PATH};
      $ENV{LD_LIBRARY_PATH} .= ':/opt/gnu/lib';
      $ConfigureEnvArgs = 'CC=egcc CXX=eg++';
      $Compiler       = 'egcc';

      # Possible NSPR bug... If USE_PTHREADS is defined, then
      #   _PR_HAVE_ATOMIC_CAS gets defined (erroneously?) and
      #   libnspr21 does not work.
      $NSPRArgs      .= 'CLASSIC_NSPR=1 NS_USE_GCC=1 NS_USE_NATIVE=';
    } else {
      # This is utterly lame....
      if ($ENV{HOST} eq 'fugu') {
        $ENV{PATH}    = "/tools/ns/workshop/bin:/usrlocal/bin:$ENV{PATH}";
        $ENV{LD_LIBRARY_PATH} = '/tools/ns/workshop/lib:/usrlocal/lib:'
                      . $ENV{LD_LIBRARY_PATH};
        $ConfigureEnvArgs = 'CC=cc CXX=CC';
        $comptmp      = `cc -V 2>&1 | head -1`;
        chomp($comptmp);
        $Compiler     = "cc/CC \($comptmp\)";
        $NSPRArgs    .= 'NS_USE_NATIVE=1';
      } else {
        $NSPRArgs    .= 'NS_USE_GCC=1 NS_USE_NATIVE=';
      }
      if ($OSVerMajor eq '5') {
        $NSPRArgs    .= ' USE_PTHREADS=1';
      }
    }
  }
  #print "Path after:  $ENV{PATH}\n";
}

sub LoadConfig {
  if (-r 'tinder-config.pl') {
    require 'tinder-config.pl';
  } else {
    warn "Error: Need tinderbox config file, tinder-config.pl\n";
    warn "       To get started, run the following,\n";
    warn "          $0 --example-config > tinder-config.pl\n";
    exit;
  }

}

sub BuildIt {
  my $EarlyExit, $LastTime, $SaveCVSCO, $comptmp;

  die "\$BuildName is the empty string ('')\n" if $BuildName eq '';

  $comptmp = '';
  $jflag   = '';
  
  mkdir $DirName, 0777;
  chdir $DirName or die "Couldn't enter $DirName";
  
  $StartDir  = getcwd();
  $LastTime  = 0;
  $EarlyExit = 0;
  $SaveCVSCO = $CVSCO;
  
  print "Starting dir is : $StartDir\n";
  
  while (not $EarlyExit) {
    chdir $StartDir;

    if (not $TestOnly and (time - $LastTime < (60 * $BuildSleep))) {
      $SleepTime = (60 * $BuildSleep) - (time - $LastTime);
      print "\n\nSleeping $SleepTime seconds ...\n";
      sleep $SleepTime;
    }
    $LastTime = time;
    
    if ($UseTimeStamp) {
      $CVSCO = $SaveCVSCO;
    } else {
      $CVSCO = $SaveCVSCO . ' -A';
    }
    $StartTime = time;
    
    if ($UseTimeStamp) {
      $BuildStart = `date '+%D %H:%M'`;
      chomp($BuildStart);
      $CVSCO .= " -D '$BuildStart'";
    }

    &MailStartBuildMessage if $ReportStatus;

    $CurrentDir = getcwd();
    if ($CurrentDir ne $StartDir) {
      print "startdir: $StartDir, curdir $CurrentDir\n";
      die "curdir != startdir";
    }
    
    $BuildDir = $CurrentDir;
    
    unlink $logfile;
    
    print "Opening $logfile\n";

    open LOG, ">$logfile" or print "can't open $?\n";
    print LOG "current dir is -- " . $ENV{HOST} . ":$CurrentDir\n";
    print LOG "Build Administrator is $BuildAdministrator\n";
    &PrintEnv;
    if ($Compiler ne '') {
      print LOG "===============================\n";
      if ($Compiler eq 'gcc' or $Compiler eq 'egcc') {
        $comptmp = `$Compiler --version`;
        chomp($comptmp);
        print LOG "Compiler is -- $Compiler \($comptmp\)\n";
      } else {
        print LOG "Compiler is -- $Compiler\n";
      }
      print LOG "===============================\n";
    }
    
    $BuildStatus = 0;

    mkdir $TopLevel, 0777;
    chdir $TopLevel or die "chdir($TopLevel): $!\n";

    unless ($TestOnly) {
      print "$CVS $CVSCO mozilla/client.mk\n";
      print LOG "$CVS $CVSCO mozilla/client.mk\n";
      open PULL, "$CVS $CVSCO mozilla/client.mk 2>&1 |" or die "open: $!\n";
      while (<PULL>) {
        print $_;
        print LOG $_;
      }
      close PULL;
    }
    
    chdir $Topsrcdir or die "chdir $Topsrcdir: $!\n";
    
    #Delete the binaries before rebuilding
    unless ($TestOnly) {
      
	  # Only delete if it exists.
	  if (&BinaryExists($fe)) {
		print LOG "deleting existing binary: $fe\n";
		&DeleteBinary($fe);
	  } else {
		print LOG "no binary detected, can't delete.\n";
	  }

    }
    
    $ENV{MOZ_CO_DATE} = "$BuildStart" if $UseTimeStamp;
    
	# Don't build if testing smoke tests.
	unless ($TestOnly) {

	  # If we are building depend, don't clobber.
	  if ($BuildDepend) {
		print LOG "$Make -f client.mk\n";
		open MAKEDEPEND, "$Make -f client.mk 2>&1 |";
		while (<MAKEDEPEND>) {
		  print $_;
		  print LOG $_;
		}
		close MAKEDEPEND;
	  } else {
		# Building clobber
        print LOG "$Make -f client.mk checkout realclean build 2>&1 |\n";
        open MAKECLOBBER, "$Make -f client.mk checkout realclean build 2>&1 |";
        while (<MAKECLOBBER>) {
          print $_;
          print LOG $_;
        }
        close MAKECLOBBER;
      }

    } # unless ($TestOnly)
    
	  if (&BinaryExists($fe)) {
		if ($RunTest) {
		  print LOG "export binary exists, build successful. Testing...\n";
		  $BuildStatus = &RunAliveTest($fe);
		  if ($BuildStatus == 0 and $BloatStats) {
			$BuildStatusStr = 'success';
			print LOG "export binary exists, build successful. Gathering bloat stats...\n";
			$BuildStatus = &RunBloatTest($fe);
		  }
		} else {
		  print LOG "export binary exists, build successful. Skipping test.\n";
		  $BuildStatus = 0;
		}
	  } else {
		print LOG "export binary missing, build FAILED\n";
		$BuildStatus = 666;
	  } # if (&BinaryExists($fe))


	if ($BuildStatus == 0) {
	  $BuildStatusStr = 'success';
	}
	elsif ($BuildStatus == 333) {
	  $BuildStatusStr = 'testfailed';
	} else {
	  $BuildStatusStr = 'busted';
	}
	print LOG "tinderbox: tree: $BuildTree\n";
	print LOG "tinderbox: builddate: $StartTime\n";
	print LOG "tinderbox: status: $BuildStatusStr\n";
	print LOG "tinderbox: build: $BuildName\n";
	print LOG "tinderbox: errorparser: unix\n";
	print LOG "tinderbox: buildfamily: unix\n";
	print LOG "tinderbox: version: $Version\n";
	print LOG "tinderbox: END\n";            
    
    close LOG;
    chdir $StartDir;
    
    # This fun line added on 2/5/98. do not remove. Translated to english,
    # that's "take any line longer than 1000 characters, and split it into less
    # than 1000 char lines.  If any of the resulting lines is
    # a dot on a line by itself, replace that with a blank line."  
    # This is to prevent cases where a <cr>.<cr> occurs in the log file. 
    # Sendmail interprets that as the end of the mail, and truncates the
    # log before it gets to Tinderbox.  (terry weismann, chris yeh)
    #
    # This was replaced by a perl 'port' of the above, writen by 
    # preed@netscape.com; good things: no need for system() call, and now it's
    # all in perl, so we don't have to do OS checking like before.
    #
    open LOG, "$logfile" or die "Couldn't open logfile: $!\n";
    open OUTLOG, ">${logfile}.last" or die "Couldn't open logfile: $!\n";
    
    while (<LOG>) {
      for ($q = 0; ; $q++) {
        $val = $q * 1000;
        $Output = substr $_, $val, 1000;
        
        last if $Output eq undef;
        
        $Output =~ s/^\.$//g;
        $Output =~ s/\n//g;
        print OUTLOG "$Output\n";
      }
    }
    
    close LOG;
    close OUTLOG;
    
    system("$mail $Tinderbox_server < ${logfile}.last") if $ReportStatus;
    unlink("$logfile");
    
    # If this is a test run, set early_exit to 0. 
    # This mean one loop of execution
    $EarlyExit++ if $BuildOnce;
  }
}

sub MailStartBuildMessage {
  
  open LOG, "|$mail $Tinderbox_server";

  print LOG "\n";
  print LOG "tinderbox: tree: $BuildTree\n";
  print LOG "tinderbox: builddate: $StartTime\n";
  print LOG "tinderbox: status: building\n";
  print LOG "tinderbox: build: $BuildName\n";
  print LOG "tinderbox: errorparser: unix\n";
  print LOG "tinderbox: buildfamily: unix\n";
  print LOG "tinderbox: version: $Version\n";
  print LOG "tinderbox: END\n";
  print LOG "\n";

  close LOG;
}

# check for the existence of the binary
sub BinaryExists {
  my ($fe) = @_;
  my $BinName;
  
  $BinName = "$BuildDir/$TopLevel/$Topsrcdir/$RelBinaryName";
  
  if (-e $BinName and -x _ and -s _) {
    print LOG "$BinName exists, is nonzero, and executable.\n";  
    1;
  }
  else {
    print LOG "$BinName doesn't exist, is zero-size, or not executable.\n";
    0;
  } 
}

sub DeleteBinary {
  my ($fe) = @_;
  my $BinName;

  print LOG "DeleteBinary: fe      = $fe\n";
  
  $BinName = "$BuildDir/$TopLevel/${Topsrcdir}/$RelBinaryName";

  print LOG "unlinking $BinName\n";
  unlink $BinName or print LOG "ERROR: Unlinking $BinName failed\n";
}

sub PrintEnv {
  my($key);
  foreach $key (sort keys %ENV) {
    print LOG "$key=$ENV{$key}\n";
    print "$key=$ENV{$key}\n";
  }
  if (-e $ENV{MOZCONFIG}) {
    print LOG "-->mozconfig<----------------------------------------\n";
    print     "-->mozconfig<----------------------------------------\n";
    open CONFIG, "$ENV{MOZCONFIG}";
    while (<CONFIG>) {
      print LOG "$_";
      print     "$_";
    }
    close CONFIG;
    print LOG "-->end mozconfig<----------------------------------------\n";
    print     "-->end mozconfig<----------------------------------------\n";
  }
}

sub killer {
  &killproc($pid);
}

sub killproc {
  my ($local_pid) = @_;
  my $status;

  # try to kill 3 times, then try a kill -9
  for ($i=0; $i < 3; $i++) {
    kill('TERM',$local_pid);
    # give it 3 seconds to actually die
    sleep 3;
    $status = waitpid($local_pid, WNOHANG());
    last if $status != 0;
  }
  return $status;
}

sub RunAliveTest {
  my ($fe) = @_;
  my $Binary;
  my $status = 0;
  my $waittime = 45;
  $fe = 'x' unless defined $fe;
  
  $ENV{LD_LIBRARY_PATH} = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $ENV{MOZILLA_FIVE_HOME} = $ENV{LD_LIBRARY_PATH};
  $Binary = "$BuildDir/$TopLevel/$Topsrcdir/$RelBinaryName";
  
  print LOG "$Binary\n";
  $BinaryDir = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $Binary    = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin/mozilla-bin";
  $BinaryLog = $BuildDir . '/runlog';
  
  # Fork off a child process.
  $pid = fork;

  unless ($pid) { # child
    
    chdir $BinaryDir;
    unlink $BinaryLog;
    $SaveHome = $ENV{HOME};
    $ENV{HOME} = $BinaryDir;
    open STDOUT, ">$BinaryLog";
    select STDOUT; $| = 1; # make STDOUT unbuffered
    open STDERR,">&STDOUT";
    select STDERR; $| = 1; # make STDERR unbuffered
    exec $Binary;
    close STDOUT;
    close STDERR;
    $ENV{HOME} = $SaveHome;
    die "Couldn't exec()";
  }
  
  # parent - wait $waittime seconds then check on child
  sleep $waittime;
  $status = waitpid($pid, WNOHANG());

  print LOG "Client quit Alive Test with status $status\n";
  if ($status != 0) {
    print LOG "$Binary has crashed or quit on the AliveTest.  Turn the tree orange now.\n";
    print LOG "----------- failure output from mozilla-bin for alive test --------------- \n";
    open READRUNLOG, "$BinaryLog";
    while (<READRUNLOG>) {
      print $_;
      print LOG $_;
    }
    close READRUNLOG;
    print LOG "--------------- End of AliveTest Output -------------------- \n";
    return 333;
  }
  
  print LOG "Success! $Binary is still running.\n";

  &killproc($pid);

  print LOG "----------- success output from mozilla-bin for alive test --------------- \n";
  open READRUNLOG, "$BinaryLog";
  while (<READRUNLOG>) {
    print $_;
    print LOG $_;
  }
  close READRUNLOG;
  print LOG "--------------- End of AliveTest Output -------------------- \n";
  return 0;
}

sub RunBloatTest {
  my ($fe) = @_;
  my $Binary;
  my $status = 0;
  $fe = 'x' unless defined $fe;

  print LOG "in runBloatTest\n";

  $ENV{LD_LIBRARY_PATH} = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $ENV{MOZILLA_FIVE_HOME} = $ENV{LD_LIBRARY_PATH};

  # Turn on ref counting to track leaks (bloaty tool).
  $ENV{XPCOM_MEM_BLOAT_LOG} = "1";

  $Binary    = "$BuildDir/$TopLevel/$Topsrcdir/$RelBinaryName";
  $BinaryDir = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $BinaryLog = $BuildDir . '/bloat-cur.log';
  
  rename ($BinaryLog, "$BuildDir/bloat-prev.log");
  
  # Fork off a child process.
  $pid = fork;

  unless ($pid) { # child
    chdir $BinaryDir;

    $SaveHome = $ENV{HOME};
    $ENV{HOME} = $BinaryDir;
    open STDOUT, ">$BinaryLog";
    select STDOUT; $| = 1; # make STDOUT unbuffered
    open STDERR,">&STDOUT";
    select STDERR; $| = 1; # make STDERR unbuffered

	if (-e "bloaturls.txt") {
	  $cmd = "$Binary -f bloaturls.txt";
	  print LOG $cmd;
	  exec ($cmd);
	} else {
	  print LOG "ERROR: bloaturls.txt does not exist.";
	}

    close STDOUT;
    close STDERR;
    $ENV{HOME} = $SaveHome;
    die "Couldn't exec()";
  }
  
  # Set up a timer with a signal handler.
  $SIG{ALRM} = \&killer;

  # Wait 30 seconds, then kill the process if it's still alive.
  alarm 30;

  $status = waitpid($pid, 0);

  # Clear the alarm so we don't kill the next test!
  alarm 0;

  print LOG "Client quit Bloat Test with status $status\n";
  if ($status == 0) {
    print LOG "$Binary has crashed or quit on the BloatTest.  Turn the tree orange now.\n";
    print LOG "----------- failure Output from mozilla-bin for BloatTest --------------- \n";
    open READRUNLOG, "$BinaryLog";
    while (<READRUNLOG>) {
      print $_;
      print LOG $_;
    }
    close READRUNLOG;
    print LOG "--------------- End of BloatTest Output -------------------- \n";
	return 333;
  }

  print LOG "<a href=#bloat>\n######################## BLOAT STATISTICS\n";

  
  open DIFF, "$BuildDir/../bloatdiff.pl $BuildDir/bloat-prev.log $BinaryLog |" or 
	die "Unable to run bloatdiff.pl";

  while (my $line = <DIFF>) {
    print LOG $line;
  }
  close(DIFF);
  print LOG "######################## END BLOAT STATISTICS\n</a>\n";
  
  print LOG "----------- success output from mozilla-bin for BloatTest --------------- \n";
  open READRUNLOG, "$BinaryLog";
  while (<READRUNLOG>) {
    print $_;
    print LOG $_;
  }
  close READRUNLOG;
  print LOG "--------------- End of BloatTest Output -------------------- \n";
  return 0;
  
}

__END__
#- PLEASE FILL THIS IN WITH YOUR PROPER EMAIL ADDRESS
$BuildAdministrator = "$ENV{USER}\@$ENV{HOST}";

#- You'll need to change these to suit your machine's needs
$BaseDir       = '/builds/tinderbox/SeaMonkey';
$DisplayServer = ':0.0';

#- Default values of command-line opts
#-
$BuildDepend  = 1;  # Depend or Clobber
$ReportStatus = 1;  # Send results to server, or not
$BuildOnce    = 0;  # Build once, don't send results to server
$RunTest      = 1;  # Run the smoke tests on successful build, or not
$UseTimeStamp = 1;  # Use the CVS 'pull-by-timestamp' option, or not
$TestOnly     = 0;  # Only run tests, don't pull/build

#- Set these to what makes sense for your system
$Make          = 'gmake'; # Must be GNU make
$MakeOverrides = '';
$mail          = '/bin/mail';
$CVS           = 'cvs -q';
$CVSCO         = 'checkout -P';

#- Set these proper values for your tinderbox server
$Tinderbox_server = 'tinderbox-daemon@cvs-mirror.mozilla.org';

#-
#- The rest should not need to be changed
#-

#- Minimum wait period from start of build to start of next build in minutes.
$BuildSleep = 10;

#- Until you get the script working. When it works,
#- change to the tree you're actually building
$BuildTree  = 'MozillaTest'; 

$BuildName        = '';
$BuildTag         = '';
$BuildObjName     = '';
$BuildConfigDir   = 'mozilla/config';
$BuildStart       = '';
$TopLevel         = '.';
$Topsrcdir        = 'mozilla';
$ClobberStr       = 'realclean';
$ConfigureEnvArgs = '';
$ConfigureArgs    = ' --cache-file=/dev/null ';
$ConfigGuess      = './build/autoconf/config.guess';
$Logfile          = '${BuildDir}.log';
$Compiler         = 'gcc';
$ShellOverride    = ''; # Only used if the default shell is too stupid

# Need to end with a true value, (since we're using "require").
1;
