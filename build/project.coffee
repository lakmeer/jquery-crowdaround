#
# Project make process specification
#

project =

    # Uses uglify to minify output if true
    minify : true

    # Disable CoffeeScript safety context
    bare : false

    # Specify directories or files to monitor for file writes
    monitor : [
        "src"
        "build/project.coffee"
    ]

    # Target file contains resulting compiled code
    target : "crowdaround.min.js"

    # List of source files, in concatenation order
    source : [
        'src/crowdaround.coffee'
    ]
