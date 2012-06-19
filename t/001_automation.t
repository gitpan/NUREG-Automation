use Test::More;
use Test::Exception;

use FindBin;
use Cwd 'abs_path';
use Carp::Heavy;

#
# can it be used?
#
use_ok('NUREG::Automation');


#
# check for exported subs
#
can_ok(__PACKAGE__, qw(dist_dir dist_file js_file appname));


#
# see if file and dir calls work.
#
###### preparation: must fake @INC
###### causes additional errors when tests fail, be warned!

@INC = ();
dies_ok{ dist_dir('NUREG-Automation') } 'dist_dir dies when no dir found';
push @INC, $FindBin::Bin;
lives_ok{ dist_dir('NUREG-Automation') } 'dist_dir lives when dir found';
is (abs_path(dist_dir('NUREG-Automation')),
    abs_path("$FindBin::Bin/auto/share/dist/NUREG-Automation"),
    'dist dir looks right');

@INC = ();
push @INC, "$FindBin::Bin/../", "$FindBin::Bin";
lives_ok { dist_file('js/json_args.js') } 'dist_file lives on existing files';
dies_ok { dist_file('js/not_existing.txt') } 'dist_file dies on non-existing files';
is( abs_path(dist_file('js/json_args.js')), 
    abs_path("$FindBin::Bin/../share/js/json_args.js"),
    'dist_file gets correct uninstalled path' );

lives_ok { js_file('json_args.js') } 'js_file lives on existing files';
dies_ok { js_file('not_existing.txt') } 'js_file dies on non-existing files';
is( abs_path(js_file('json_args.js')), 
    abs_path("$FindBin::Bin/../share/js/json_args.js"),
    'js_file gets correct uninstalled path' );

is(abs_path(dist_file('blabla.txt')),
   abs_path("$FindBin::Bin/auto/share/dist/NUREG-Automation/blabla.txt"),
   'dist_file gives right answer over dist');
is(abs_path(js_file('blabla2.txt')),
   abs_path("$FindBin::Bin/auto/share/dist/NUREG-Automation/js/blabla2.txt"),
   'js_file gives right answer over dist');


#
# appname mangling
#
is(appname('Bla CS1'),                            'Bla CS1', 'appname w/o opts looks good');
is(appname('Bla CS1', undef),                     'Bla CS1', 'appname w/ undef opts looks good');
is(appname('Bla CS1', []),                        'Bla CS1', 'appname w/ arrayref opts looks good');
is(appname('Bla CS1', {}),                        'Bla CS1', 'appname w/ empty hashref opts looks good');
is(appname('Bla CS1', {b => 1}),                  'Bla CS1', 'appname w/ nonsense hashref opts looks good');
is(appname('Bla CS1', {c => 'S7'}),               'Bla CS1', 'appname w/ right but lc hashref opts looks good');
is(appname('Bla CS1', {C => 'X8'}),               'Bla CX8', 'appname w/ C opt looks good');
is(appname('Bla CS1', {C => 'X8', a => 'Blubb'}), 'Blubb',   'appname w/ a opt looks good');


#
# we are done
#
done_testing;
