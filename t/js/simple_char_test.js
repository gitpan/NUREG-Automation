#include "json_args.js"

function main(args) {
    var result = { };
    
    // we get: args['word'] == 'Für'.
    
    result['strlen'] = args['word'].length;
    result['codes'] = [];
    for (var i=0; i < args['word'].length; i++) {
        result['codes'].push( args['word'].charCodeAt(i) );
    }
    
    return result;
}
