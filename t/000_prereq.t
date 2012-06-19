use Test::More;
use Test::Exception;

my $OSASCRIPT = '/usr/bin/osascript';

ok(-f $OSASCRIPT, 'osascript file exists');
ok(-x $OSASCRIPT, 'osascript file is executable');

# needed to avoid the trap that QXPScriptingAdditions.osax is installed
like(`$OSASCRIPT -e 'tell application "Finder" to return "123xyz"' 2>&1`,
     qr{\A 123xyz \s* \z}xms,
     'primitive osascript result looks good');

done_testing;
