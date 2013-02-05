
fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
async = require 'async'
blade = require 'blade'
Asset = require('../index').Asset


class exports.BladeAsset extends Asset
  mimetype: 'text/javascript'

  create: =>
    @dirname = @options.dirname
    @filenames = if @options.filenames? then @options.filenames else @getFilenames(@options.dirname)
    @separator = @options.separator or '/'
    @compress = @options.compress or false
    @clientVariable = @options.clientVariable or 'Templates'
    
    async.map @filenames, @compile, (err, tmpls)=>
      @emit('error', err) if err?
      @contents = "window.#{@clientVariable} = {"
      for tmpl in tmpls
        @contents += "'#{tmpl.filename}': #{tmpl.toString()},"
      @contents += '};'
      @contents = uglify.minify(@contents, { fromString: true }).code if @compress
      @emit 'complete'
    
  getFilenames: (dirname) ->
    filenames = fs.readdirSync dirname
    paths = []
    for filename in filenames
      continue if filename.slice(0, 1) is '.'
      path = pathutil.join dirname, filename
      stats = fs.statSync path
      if stats.isDirectory()
        paths = paths.concat @getFilenames path
      else if pathutil.extname(path) == '.blade'
        paths.push(path)
    paths

  compile: (filename, cb)=>
    options = 
      cache: process.env.NODE_ENV == "production",
      minify: false
      includeSource: process.env.NODE_ENV == "development",
      basedir: @dirname
      middleware: true
    blade.compileFile filename, options, cb
