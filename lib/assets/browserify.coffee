
fs = require 'fs'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require 'uglify-js'
crypto = require 'crypto'
Asset = require('../index').Asset

class exports.BrowserifyAsset extends Asset
  mimetype: 'text/javascript'

  create: ->
    @filename = @options.filename
    @require = @options.require
    @debug = @options.debug or false
    @compress = @options.compress or false
    @watch = @options.watch or false
    @extensionHandlers = @options.extensionHandlers or []
    agent = browserify watch: @watch, debug: @debug
    agent.on 'syntaxError', (err)=>
      @emit 'error', err
    for handler in @extensionHandlers
      agent.register(handler.ext, handler.handler)
    agent.addEntry @filename if @filename?
    agent.require @require if @require?
    

    @setContents(agent.bundle())
    if @watch == true
      agent.on 'bundle', ()=>
        @setContents(agent.bundle())
      

  setContents: (bundle)->
    if @options.compress is true
      @contents = uglify.minify(bundle, { fromString: true }).code
    else
      @contents = bundle
    @emit 'complete'

