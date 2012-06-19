
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "Nureg automation reloaded",
  "AUTHOR" => "Wolfgang Kinkeldei <wolfgang\@kinkeldei.de>",
  "BUILD_REQUIRES" => {
    "Carp::Heavy" => 0,
    "Test::Exception" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "File::ShareDir::Install" => "0.03"
  },
  "DISTNAME" => "NUREG-Automation",
  "EXE_FILES" => [
    "bin/indesign_do.pl",
    "bin/indesign_load_pdf_presets.pl"
  ],
  "LICENSE" => "perl",
  "NAME" => "NUREG::Automation",
  "PREREQ_PM" => {
    "Cwd" => 0,
    "Data::Dumper" => 0,
    "Exporter" => 0,
    "File::ShareDir" => 0,
    "FindBin" => 0,
    "Getopt::Std" => 0,
    "IPC::Open3" => 0,
    "JSON" => 0,
    "base" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.03",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}


