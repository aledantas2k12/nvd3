module.exports = (grunt)->
    flatten = (a, b)-> a.concat b

    files = [
        'core'
        'utils'
        'layer'
        'interactiveLayer'
        'tooltip'
        'utils'
        'models/axis'
        'models/legend'
        'models/distribution'
        'chart'
        'models/bar/**/*'
        'models/bullet/**/*'
        'models/line/**/*'
        'models/pie/pie*'
        'models/pie/donut'
        'models/scatter/**/*'
        'models/sparkline/**/*'
        'models/stackedArea/**/*'
    ]

    # Project configuration.

    gruntConfig =

        pkg: grunt.file.readJSON('package.json')

        concat:
            options:
                separator: '\n'
                # UMD Banner for AMD, CommonJS, and globals
                banner: """
                (function (root, factory) {
                    if (typeof define === 'function' && define.amd) {
                        // AMD. Register as an anonymous module.
                        define(['exports', 'd3'], factory);
                    } else if (typeof exports === 'object') {
                        // CommonJS
                        factory(exports, require('d3'));
                    } else {
                        // Browser globals
                        factory((root.nv = {}), root.d3);
                    }
                }(this, function (exports, d3) {

                """
                footer: """

                exports = nv;

                return nv;

                }));
                """
            dist:
                src: files.map (file) ->
                    'src/' + file + '.js'
                dest: 'nv.d3.js'

        uglify:
            options:
                banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' +
                    '<%= grunt.template.today("yyyy-mm-dd") %> */'
            js:
                files:
                    'nv.d3.min.js': ['nv.d3.js']

        jshint:
            foo:
                src: "src/**/*.js"
            options:
                jshintrc: '.jshintrc'
        watch:
            js:
                files: ["src/**/*.js"],
                tasks: ['concat']
        copy:
          css:
            files: [
              { src: 'src/nv.d3.css', dest: 'nv.d3.css' }
            ]

        cssmin:
          dist:
            files:
              'nv.d3.min.css' : ['nv.d3.css']

        mochaTest:
          nvd3:
            options:
              reporter: 'spec'
            src: ['test/runner/loadAll.coffee']

        connect:
          options:
            port: 8808
          test: {},
          serve:
            options:
              keepalive: true
        karma:
            client:
                options:
                    browsers: ['Chrome']
                    frameworks: [ 'mocha', 'sinon-chai' ]
                    reporters: [ 'spec' ]
                    singleRun: true
                    preprocessors: {
                        'test/**/*.coffee': ['coffee']
                    }
                    files: [
                        'bower_components/d3/d3.js'
                        'bower_components/jquery/dist/jquery.js'
                        files.map (d)-> "src/#{d}.js"
                        'test/tools/**/*.coffee'
                        files.map (d)-> "test/unit/#{d}.coffee"
                    ].reduce(flatten, [])
                    coverageReporter:
                        type: 'lcov'
                        dir: 'build/coverage/'

    grunt.initConfig gruntConfig

    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-concat')
    grunt.loadNpmTasks('grunt-contrib-jshint')
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-copy')
    grunt.loadNpmTasks('grunt-contrib-cssmin')
    grunt.loadNpmTasks('grunt-contrib-connect')
    grunt.loadNpmTasks('grunt-mocha-test')
    grunt.loadNpmTasks('grunt-selenium-launcher')
    grunt.loadNpmTasks('grunt-karma')

    grunt.registerTask('test', ['connect:test', 'selenium-launch', 'mochaTest:nvd3'])

    grunt.registerTask('default', ['karma', 'concat', 'copy', 'test'])
    grunt.registerTask('production', ['concat', 'uglify', 'copy', 'cssmin'])
    grunt.registerTask('release', ['production'])
    grunt.registerTask('lint', ['jshint'])
