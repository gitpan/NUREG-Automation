#include "json_args.js"

function main(args) {
    var fonts = [];
    
    for (var i=0; i<app.fonts.length; i++) {
        var status = 'unknown';
        switch(app.fonts[i].status) {
            case FontStatus.INSTALLED :     status = 'installed'; break;
            case FontStatus.FAUXED :        status = 'fauxed'; break;
            case FontStatus.NOT_AVAILABLE : status = 'not_available'; break;
            case FontStatus.SUBSTITUTED :   status = 'substituted'; break;
        }
        
        fonts.push( { 
            name:   app.fonts[i].name,
            family: app.fonts[i].fontFamily,
            valid:  app.fonts[i].isValid,
            status: status
        } );
    }
    
    return {OK: true, fonts: fonts};
}