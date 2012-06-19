#include "json_args.js"

//
// expect to get an array of paths to load
// args['files'] = [ path, ... ]
// the base filename is the name for the setting.
//
function main(args) {
    var files = args['files'];
    if (!files || !files.length) return {Error: 'No files given to work on'};
    
    var nr_files = 0;
    for (var i = 0; i < args['files'].length; i++) {
        var path = args['files'][i];
        var name = path.replace(/^.*\/(.*?)(\.\w+)?$/, '$1');
        
        if (app.pdfExportPresets.itemByName(name).isValid)
            app.pdfExportPresets.itemByName(name).remove();
        
        app.importFile( ExportPresetFormat.PDF_EXPORT_PRESETS_FORMAT, 
                        new File(path) );
        nr_files++;
    }
    
    return {OK: true, nr_files: nr_files};
}
