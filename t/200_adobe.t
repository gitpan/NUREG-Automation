use Test::More;
use Test::Exception;
use FindBin;

my @APPS = (# 'Adobe InDesign CS4',
            'Adobe InDesign CS5',
            # 'Adobe Photoshop CS4',
            'Adobe Photoshop CS5',
            );

#
# can it be used?
#
use_ok('NUREG::Automation::JS');

SKIP:
foreach my $app (@APPS) {
    SKIP: {
        if (!-d "/Applications/$app") {
            skip "APP $app not found, skipping", 10;
        }
        #
        # calling a javascript and inspect the raw result
        #
        # inline scripts
        is_deeply( javascript($app, [ q{'{"result": ' + (21+21) + '}'} ]), 
                   {result => 42}, 
                   "$app: inline script returns result as expected" );
        is( javascript($app, [ q{"";} ]), 
            '', 
            "$app: inline script returns empty string as expected" );
        is( javascript($app, [ q{42;} ]), 
            42, 
            "$app: inline script returns number as expected" );
        
        # file-based scripts
        is_deeply( javascript($app, "$FindBin::Bin/js/return42.js"), 
                   {result => 42}, 
                   "$app: file script returns result as expected" );
        
        #
        # see if include works
        #
        my $js = <<EOF;
#include "$FindBin::Bin/js/json_args.js"

function main(args) {
    args = args || {};
    var result = { bla: 13 };
    result['bla'] = args['foo']; // must change 13 to 42
    result['Saw'] = 'bar:' + args['bar'];
    
    return result;
}
EOF
        
        is_deeply( javascript($app,
                              {
                                  source => $js,
                                  # function => 'nonsense',
                                  args   => { foo => 42, bar => 'baz' },
                              }),
                   { bla => 42, Saw => 'bar:baz' },
                   "$app: include inside literal source code w/ absolute path works" );
        
        is_deeply( javascript($app,
                              {
                                  file   => "$FindBin::Bin/js/simple_arg_test.js",
                                  args   => { foo => 84, bar => 'bay' },
                              }),
                   { bla => 84, Saw => 'bar:bay' },
                   "$app: include inside file-script w/ absolute path works" );
        
        #
        # ensure we do not encounter encoding issues
        #
        is_deeply( javascript($app,  # part 1: decode in JavaScript
                              {
                                  file   => "$FindBin::Bin/js/simple_char_test.js",
                                  args   => { word => "F\x{00fc}r" }, # german: "Für"
                              }),
                   { strlen => 3, codes => [70, 252, 114] },
                   "$app: character encoding looks good" );
        
        is_deeply( javascript($app, # part 2: encode in JavaScript
                              {
                                  file   => "$FindBin::Bin/js/construct_string_test.js",
                                  args   => { characters => [42, 128, 255, 2002] },
                              }),
                   { string => chr(42) . chr(128) . chr(255) . chr(2002) . chr(252) },
                   "$app: a javascript composed string looks good" );
        
        #
        # test if arg-handler handles (=rethrows) exceptions correctly
        #
        ### GOTCHA: photoshop displays a dialog here
        if ($app =~ m{InDesign}xms) {
            dies_ok { javascript($app, "$FindBin::Bin/js/json_args.js") }
                    "$app: calling the arg-handler w/o script dies";
            
            dies_ok { javascript($app, "$FindBin::Bin/js/simple_exception_test.js") }
                      "$app: calling an exception-throwing script dies";
        }
    };
}

#
# we are done
#
done_testing;
