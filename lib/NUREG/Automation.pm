use NUREG::Automation;
use strict;
use warnings;

# ABSTRACT: Nureg automation reloaded

use base qw(Exporter);

use FindBin;
use Cwd 'abs_path';
use File::ShareDir;

our @EXPORT = qw(dist_dir dist_file js_file 
                 appname set_relative_share_path);

our $relative_share_path = '..';

sub set_relative_share_path {
    my $relative_path = shift;
    
    if (!defined($relative_path) || $relative_path eq '') {
        $relative_path = '.';
    }
    
    $relative_share_path = $relative_path;
}

sub dist_dir {
    File::ShareDir::dist_dir('NUREG-Automation');
}

sub dist_file {
    my $file = shift;
    
    my $file_path = abs_path("$FindBin::Bin/$relative_share_path/share/$file");
    
    return $file_path if (-f $file_path);
    return File::ShareDir::dist_file('NUREG-Automation', $file);
}

sub js_file   { 
    dist_file("js/$_[0]");
}

#
# determine appname from a list of options
# typical usage:
#   -CS4  ==> Adobe xxx CS4
#   -a Adobe InDesign CS7
#
sub appname {
    my ($appname, $opts) = @_;
    
    # trivial case: no opts given -- use Std Appname
    return $appname if (!$opts || ref($opts) ne 'HASH' ||
                        (!exists($opts->{a}) && !exists($opts->{C})));
    
    # simple case: app given as option
    return $opts->{a} if ($opts->{a});
    
    $appname =~ s{CS\d+\z}{C$opts->{C}}xms;
    return $appname;
}

1;
