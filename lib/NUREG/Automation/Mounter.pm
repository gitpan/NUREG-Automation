package NUREG::Automation::Mounter;
{
  $NUREG::Automation::Mounter::VERSION = '0.03';
}
use strict;
use warnings;

use base qw(Exporter);

our @EXPORT = qw(mount is_mounted);

#
# einfacher Helfer um Volumes zu mounten.
#   - Login-Daten evtl. aus Schlüsselbund holen
#   - User/Passwort direkt angeben
#
#
# mount('user:pass@xs-adidas.nureg.intra/volume_name');
# `security find-internet-password -g -s server`

sub mount {
    return if (is_mounted(@_));
    
    # check if /Volumes/xxx already there -- die
    
    # mkdir /Volumes/xxx
    # mount
    return;
}

sub is_mounted {
    return 0;
}

1;
