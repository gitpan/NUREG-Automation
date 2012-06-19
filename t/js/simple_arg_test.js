#include "json_args.js"

function main(args) {
    args = args || {};
    var result = { bla: 13 };
    result['bla'] = args['foo']; // must change 13 to 42
    result['Saw'] = 'bar:' + args['bar'];
    
    return result;
}
