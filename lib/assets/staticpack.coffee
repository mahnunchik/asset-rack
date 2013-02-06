fs = require 'fs'
glob = require 'glob'
async = require 'async'
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

    @compress = @options.compress or false

    @contents = ''
    @getFilenames (err, filenames)=>
      return @emit('error', err) if err?
      @filenames = filenames
      async.map filenames, @getFile, (err, contents)=>
        return @emit('error', err) if err?

        for content in contents
          @contents += content + "\n"

        if @compress
          if @type == 'css'
            @contents = cleanCSS.process @contents
          else
            @contents = uglify.minify(@contents, { fromString: true }).code if @compress
        @emit 'complete'

  getFilenames: (cb) ->
    if @filenames?.length > 0
      cb(null, @filenames)
    else
      glob "#{@dirname}/**/*#{@type}", cb

  getFile: (filename, cb) =>
    fs.readFile filename, 'utf8', cb