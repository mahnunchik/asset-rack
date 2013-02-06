
glob = require 'glob'
pathutil = require 'path'
uglify = require 'uglify-js'
async = require 'async'
blade = require 'blade'
Asset = require('../index').Asset


class exports.BladeAsset extends Asset
  mimetype: 'text/javascript'

  create: =>
    @dirname = @options.dirname
    @filenames = @options.filenames
    @compress = @options.compress or false
    @clientVariable = @options.clientVariable or 'Templates'

    @getFilenames (err, filenames)=> 
      return @emit('error', err) if err?
      async.map filenames, @compile, (err, tmpls)=>
        return @emit('error', err) if err?
        @contents = "window.#{@clientVariable} = {"
        for tmpl in tmpls
          @contents += "'#{tmpl.filename}': #{tmpl.toString()},"
        @contents += '};'
        @contents = uglify.minify(@contents, { fromString: true }).code if @compress
        @emit 'complete'
  
  getFilenames: (cb) ->
    if @filenames?.length > 0
      cb(null, @filenames)
    else
      glob "#{@dirname}/**/*.blade", cb

  compile: (filename, cb)=>
    options = 
      cache: process.env.NODE_ENV == "production",
      minify: false
      includeSource: process.env.NODE_ENV == "development",
      basedir: @dirname
      middleware: true
    blade.compileFile filename, options, cb
