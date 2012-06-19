use Test::More;
use Test::Exception;

#
# can it be used?
#
use_ok('NUREG::Automation::JS');

#
# check for exported subs
#
can_ok(__PACKAGE__, qw(applescript javascript));
ok( !defined(UNIVERSAL::can(__PACKAGE__, $_)), "'$_' is not exported by default" )
    for qw(to_utxt);

eval "use NUREG::Automation::JS 'to_utxt'";
can_ok(__PACKAGE__, qw(to_utxt));


#
# check if to_utxt does its job
#
is(to_utxt(qq{hello "\x{0142}"}),
   qq{\x{c7}data utxt00680065006c006c006f0020002201420022\x{c8} as Unicode text},
   'conversion looks good');

is(to_utxt(qq{hello "\x{0142}" more text}),
   qq{\x{c7}data utxt00680065006c006c006f00200022014200220020\x{c8} as Unicode text & \x{c2}\n\x{c7}data utxt006d006f0072006500200074006500780074\x{c8} as Unicode text},
   'conversion of long text looks good');

is(to_utxt(qq{hello "\x{0142}"}, 'hello_var'),
   qq{set hello_var to ""\nset hello_var to hello_var & \x{c7}data utxt00680065006c006c006f0020002201420022\x{c8} as Unicode text},
   'conversion and variable assignment looks good');

is(to_utxt(qq{hello "\x{0142}" more text}, 'hello_var'),
   qq{set hello_var to ""\nset hello_var to hello_var & \x{c7}data utxt00680065006c006c006f00200022014200220020\x{c8} as Unicode text\nset hello_var to hello_var & \x{c7}data utxt006d006f0072006500200074006500780074\x{c8} as Unicode text},
   'conversion and variable assignment looks good');

#
# check if exception handling works as expected
#
dies_ok { applescript('nonsense commands must die') } 'illegal applescript commands die';
dies_ok { applescript('tell application "Unknown Application Bla" to croak') } 'illegal applications die';
dies_ok { applescript('tell application "Adobe InDesign CS5" to activatem') } 'unknown vocabulary to apps die';

dies_ok { javascript('Adobe InDesign CS5', '/not/there/test.js') } 'not existing javascript dies';
dies_ok { javascript('Adobe InDesign CS5', ['xxx = new Object; xxx.unknown_method()']); } 'javascript errors die';

#
# non-json results are ok if numeric or empty string
#
lives_ok { javascript('Adobe InDesign CS5', [ '"";' ]) } 'empty string as result lives';
is( javascript('Adobe InDesign CS5', [ '"";' ]), '', 'empty string result looks good');
is( javascript('Adobe InDesign CS5', [ 'function xxx() {} xxx();' ]), '', 'void function call result looks good');


#
# we are done
#
done_testing;
