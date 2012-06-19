package NUREG::Automation::JS;
use strict;
use warnings;

use base qw(Exporter);

use JSON;
use IPC::Open3;

our $VERSION   = '0.03';
our $use_open3 = 1;

=head1 NAME

NUREG::Automation::JS - JavaScript script execution with Adobe Programs

=head1 VERSION

version 0.03

=head1 SYNOPSIS

    use NUREG::Automation::JS;
    
    my $result = javascript('Adobe InDesign CS4',
                            '/path/to/file.js',
                            { param => 'value', foo => 42 } );
    # OR:
    my $result = javascript('Adobe InDesign CS4',
                            [ lines of javascript ],
                            { param => 'value', foo => 42 } );
    # OR:
    my $result = javascript('Adobe InDesign CS4',
                            {
                                # specify direct javascript source
                                source => 'source code',
                                
                                # -OR- give a file for execution
                                file => '/path/to/file.js',
                                
                                # specify a function to call (default 'main')
                                function => 'function_to_call',
                                
                                # arguments to script (will convert to JSON)
                                args => { foo => 'bar' },
                                
                                # specify a timeout in seconds
                                timeout => 1800,
                                
                                # quit app before script starts (default = no)
                                quit_app_before => 0,
                            });

=head1 JAVASCRIPT

the anatomy of a typical JavaScript could look like:

    #include "json_args.js"
    
    function main(args) {
        // do something with args -- which is a hash
        
        // return anything
        return { bla: 42, status: 'whatever' }
    }

or simple inline statements like:

    function do_something() {
        // ...
    }
    
    do_something();
    
    // a return value (either numeric, empty string or valid JSON)
    '';

=head2 Gotchas

There is no include-path and the #includepath directive does not work.
Thus, every included JavaScript must have either an absolute path or must
reside in the same directory as the main JavaScript. Looks like there is
no way around.

=head1 SUBROUTINES

=cut

our @EXPORT_OK = qw(to_utxt);
our @EXPORT    = qw(applescript javascript set_open3_mode);

=head2 javascript

execute a javascript in an app

=cut

sub javascript {
    die 'javascript(): min 2 parameters needed'
        if (scalar(@_) < 2);
    my $app = shift;
    my %opts = (
        timeout  => 1800,
        function => 'main',
    );
    
    #
    # try to find the way we have been called and fill %opts
    #
    if (!ref($_[0])) {
        # a direct file and args
        $opts{file} = shift;
        $opts{args} = shift || {};
    } elsif (ref($_[0]) eq 'ARRAY') {
        # javascript source code and args
        $opts{source} = join("\n", @{ shift() });
        $opts{args}   = shift || {};
    } elsif (ref($_[0]) eq 'HASH') {
        # fill opts from a hashref
        %opts = ( %opts, args => {}, %{ shift() } );
    } else {
        die 'javascript(): illegal type of argument.';
    }
    
    if ($opts{quit_app_before}) {
        ### TODO: kill app.
        warn "killing app '$app' before script start is not yet done";
    }
    
    my $result = applescript( _generate_applescript($app, \%opts) );
    warn "RESULT: $result" if ($opts{DEBUG});
    
    return defined($result) ?
        ($result =~ m{\A \d* \s* \z}xms
        ? $result
        : from_json($result)) : undef;
}

sub _generate_applescript {
    my ($app, $opts) = @_;

    my @applescript;

    push @applescript, to_utxt(to_json($opts->{args}), 'script_arguments');
    my $arguments = qq{with arguments { script_arguments, "$opts->{function}" }};
    my $command  = '';
    my $language = '';
    my $suffix   = '';
    if ($app =~ m{InDesign}xmsi) {
        $command  = qq{do script};
        $language = qq{language javascript};
        $suffix   = qq{undo mode fast entire script};
    } elsif ($app =~ m{Photoshop}xmsi) {
        $command = qq{do javascript};
        if ($opts->{file} && !$opts->{source}) {
            # rewrite {file} to {source}, Photoshop CS5 has a Javascript Bug
            # see: http://forums.adobe.com/thread/680032
            $opts->{source} = "\$.evalFile('$opts->{file}')";
        }
    } else {
        $command = qq{do javascript};
    }
    
    if ($opts->{source}) {
        push @applescript, to_utxt($opts->{source}, 'script_source');
        push @applescript, qq{$command script_source $language $arguments $suffix};
    } elsif ($opts->{file}) {
        push @applescript, qq{$command (POSIX file "$opts->{file}") $language $arguments $suffix};
    } else {
        die "need either 'source' or 'file' option to execute JavaScript";
    }
    
    if ($opts->{timeout}) {
        unshift @applescript, qq{with timeout of $opts->{timeout} seconds};
        push @applescript,    qq{end timeout};
    }
    
    unshift @applescript, qq{tell application "$app"};
    push @applescript,    qq{end tell};
    
    print join("\n", @applescript) if $opts->{DEBUG};
    return join("\n", @applescript);
}

=head2 applescript

execute applescript code

=cut

sub applescript {
    my $script = shift;

    if (ref($script) eq 'ARRAY') {
        $script = join("\n", $script);
    }

    my ($pid, $result);
    if ($use_open3) {
        my ($in, $out, $err);
        local $/ = undef;
        
        $pid = open3($in, $out, $err, '/usr/bin/osascript', '-');
        print $in $script;
        close($in);
        $result = <$out>;
        $result =~ s{\s*\z}{}xms;
        
        waitpid($pid, 0);

        die $result if ($?);
    } else {
        $pid = open(my $in, '|-', '/usr/bin/osascript') // die "could not call osascript: $!\n";
        print $in $script;
        close($in);
        
        waitpid($pid, 0);
    }
    
    return $result;
}

=head2 to_utxt

convert a string into a multiline string that savely encodes everything right.

if a var name is given as a second argument, the string is stuffed into the given variable.
Long strings are split into parts.

=cut

sub to_utxt {
    my $src_text = shift;
    my $var_name = shift;
    my $uni_text;
    
    my $hex_text = join('',
                        map { sprintf('%04x',ord($_)) }
                        (split(//,$src_text))
                        );
    my @chunks = map { "\x{c7}data utxt$_\x{c8} as Unicode text" }
                 ($hex_text =~ m/(.{4,40})/g);
    
    if (!$var_name) {
        return join(" & \x{c2}\n", @chunks) || '""';
    } else {
        return join("\n",
                    qq{set $var_name to ""},
                    map { qq{set $var_name to $var_name & $_} } @chunks);
    }
}

=head2 set_open3_mode

set if call to osascript should be using open3 or simple open command
open3 is the default but has shown difficulties when used with launch
agents so you should set open3_mode to 0. beware, using simple open
doesn't get you any results back!

=cut

sub set_open3_mode {
    $use_open3 = shift;
}


=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>kinkeldei@nureg.deE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
