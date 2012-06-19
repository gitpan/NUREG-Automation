#include "json_args.js"

function main(args) {
    var string = '';
    
    for (var i=0; i < args.characters.length; i++) {
        string += String.fromCharCode(args.characters[i]);
    }
    
    return { string: string + '\u00FC' };
}