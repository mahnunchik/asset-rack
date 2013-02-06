fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
cleanCSS = require 'clean-css'
Asset = require('../index').Asset
_ = require 'underscore'

class exports.StaticPackAsset extends Asset
  mimetype: ''

  create: =>
    @basedir = @options.basedir
    if @options.type == 'css'
      @type = 'css'
      @fileext = '.css'
      @mimetype = 'text/css'
    else
      @type = 'js'
      @fileext = '.js'
      @mimetype = 'text/javascript'

    @dirname = @options.dirname
    if @options.filenames?
      @filenames = _.unique @options.filenames
      if @options.basedir?
        @filenames = _.map @filenames, (val)=>
          @options.basedir + val
    else
      @filenames = @getFilenames @options.dirname
    @compress = @options.compress or false

    @contents = ''
    for file in @filenames
      @contents += fs.readFileSync(file, 'utf8') + "\n"

    if @compress
      if @type == 'css'
        @contents = cleanCSS.process @contents
      else
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
      else if pathutil.extname(path) == @fileext
        paths.push(path)
    paths

