#!/usr/bin/perl
use strict;
use warnings;

use NUREG::Automation;
use NUREG::Automation::JS;
use Cwd 'abs_path';
use Getopt::Std;

#
# constants
#
my $DEFAULT_APP = 'Adobe InDesign CS4';

#
# commandline processing
#
my %opts;
getopts('C:a:s:hnv', \%opts);
usage() if ($opts{h});
my $verbose = $opts{v} ? 1 : 0;
my $dryrun  = $opts{n} ? 1 : 0;
my $script  = $opts{s} or die 'no script given!';

#
# javascript execution
#
if ($dryrun) {
    print "would use app: ", appname($DEFAULT_APP, \%opts), "\n";
    print "would exec js: ", js_file($script), "\n";
} else {
    my $result = javascript(
        appname($DEFAULT_APP, \%opts),
        js_file($script),
        { 
            argv => \@ARGV,
        }
    );
    
    use Data::Dumper; print Data::Dumper->Dump([$result], ['result']);
}

#
# help message
#
sub usage {
    my $cs = $DEFAULT_APP;
    $cs =~ s{\A .* [ ]}{}xms;
    print <<EOF;
indesign_load_pdf_presets [options] file [more files]
    loads the pdf export setting files into $DEFAULT_APP

    options:
      -CSx      specify another InDesign Version (default: $cs)
      -a app    specify full app name (default: $DEFAULT_APP)
                (obsoletes -C)
      -s script JavaScript to execute
      -h        this help
EOF
    exit;
}
