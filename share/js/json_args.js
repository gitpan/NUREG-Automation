/*
typical usage:

    #include "json_args.js"
    
    function some_function_name(args) {
        // your stuff here
        
        return {OK: true, some: 'value', another: 42};
    }

internal detail:
 - arguments[0] is a JSON-Text 
 - arguments[1] must be the name of the function to call

*/

function to_source(thing) {
    var source = thing.toSource()
                      .replace(/^\(new\s+\w+\((.*)\)\)$/, '$1');
    if (source.charAt(0) == '"') {
        // Adobe encodes some things inside strings as \xHH -- \u00HH would be right.
        source = source.replace(/\\x([0-9A-F]{2})/g, '\\u00$1');
    }
    
    // TODO: get rid of resolve(" ... ") things
    
    return source;
}

function object_to_source() {
    var s = '';
    for (var key in this) {
        s += (s.length > 0 ? ', ' : '')
           + '"' + key + '": ' 
           + to_source(this[key]);
    }
    
    return '{' + s + '}';
}

function array_to_source() {
    var s = '';
    for (var i=0; i<this.length; i++) {
        s += (s.length > 0 ? ', ' : '')
           + to_source(this[i]);
    }
    
    return '[' + s + ']';
}

try {
    var arg_source    = arguments[0];
    var function_name = arguments[1] || 'main';
    eval('var result = ' + function_name + '(' + arguments[0] + ');');
    
    // "Overload" toSource() in order to get proper JSON
    Object.prototype.toSource = object_to_source;
    Array.prototype.toSource  = array_to_source;
    result.toSource();
} catch(e) {
    // Thanks Adobe for *not* forwarding line numbers of messages
    // thru AppleScript. Thus, we need to do this ourselves.
    throw 'JavaScript Error: ' + e.name + ' (' + e.description + ') in line ' + e.line;
}
