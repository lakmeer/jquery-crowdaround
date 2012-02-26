var fs  = require('fs'),
    cs  = require('coffee-script').CoffeeScript,
    min = require('uglify-js');

// If source file contains 'coffee', requires compiling before concatenating
function needsCompiling (filename) {
    return /\.coffee$/.test(filename);
}


// Create error readout string
function errorMessage (error, file) {

    error = String(error);

    var cr     = "\\n",
        lmatch = error.match(/line (\d+)/),
        line   = lmatch ? ' | line ' + lmatch[1] : "",
        ematch = error.match(/: ([^:]+)$/),
        err    = ematch ? ematch[1] : error;

    errorString  = 'CoffeeScript Error:' + cr;
    errorString += '  ' + file + line + cr;
    errorString += '  ' + err;

    return 'console.error("' + errorString + '");';

}



// Join files, compiling and minifying where required
function catFiles (filelist, bare) {

    var text = ""

    for (var i in filelist) {

        var filename = filelist[i];

        text += compileCoffeeScript(filename, bare);

    }

    return text;

}

// Make buildspec from project file
function getBuildOptions (specfile) {

    try {
        return cs.eval(fs.readFileSync(specfile, 'utf-8'), { bare : true });
    } catch (ex) {
        console.log("Couldn't read project file:")
        console.log(ex);
        process.exit(1);
    }

}


// Compile some CoffeeScript source, return error if encountered
function compileCoffeeScript (filename, bare) {

    var text = "";

    try {

        var filetext = fs.readFileSync(filename, 'utf-8');

        text += "/*\n * " + filename + "\n *\n */\n\n\n";

        if (needsCompiling(filename)) {
            filetext = cs.compile(filetext, { bare : bare });
        }

        text += filetext
        text += "\n\n\n"

    } catch (ex) {

        switch (ex.code) {
            case "ENOENT":
                console.error("Can't find source file: " + filename);
                break;
            default:
                var formatErrMsg = errorMessage(ex, filename);
                eval(formatErrMsg);
                text += errorMessage (ex, filename);

        }

    }

    return text;

}

// Build project, copy resulting srouce to destination file
function buildProject (spec) {

    console.log("Building: " + spec.target + "...");

    var proj = catFiles(
        spec.source,
        {
            minify : spec.minify === true,
            bare   : spec.bare   === true
        }
    );

    if (spec.minify === true) {
        proj = min(proj)
    }

    fs.writeFileSync(spec.target, proj);

}

// Watch directory for filechanges
function monitorFiles (dirlist) {

    var currentTimer = 0;

    function debounce (cb) {
        clearTimeout(currentTimer);
        currentTimer = setTimeout(function () {
            cb();
        }, 200);
    }

    for (var i in dirlist) {

        var dir = dirlist[i];

        fs.watch(dir, function (event, filename) {
            if (filename) {
                if (/\.(coffee|js)$/.test(filename) && event === 'change') {
                    debounce(rebuild);
                }
            } else {
                debounce(rebuild);
            }
        });

        console.log('Monitoring ' + dir + "...");

    }
}




/*
 * INIT
 *
 */


// Get project makefile
var spec = getBuildOptions(process.argv[2]);


// If monitoring set, create file watchers
if (spec.monitor) { monitorFiles(spec.monitor); }


// Refresh function - re-read project specs so file list can change
// without restarting process. Can't change monitor settings though.

function rebuild () {
    freshSpec = getBuildOptions(process.argv[2]);
    buildProject(freshSpec);
}


// Initial build
rebuild();


