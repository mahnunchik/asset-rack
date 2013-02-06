
crypto = require 'crypto'
async = require 'async'
pathutil = require 'path'
knox = require 'knox'
EventEmitter = require('events').EventEmitter

class exports.AssetRack extends EventEmitter
  constructor: (assets=[], @options) ->
    super()
    @assets = []
    @on 'newListener', (event, listener) =>
      if event is 'complete' and @completed() is true
        listener()
    assets = @getAssets() if @getAssets?
    @addPackage(assets)
    @create() if assets?

  create: -> process.nextTick =>
    for asset in @assets
      asset.create()

  completed: =>
    for asset in @assets
      return false unless asset.completed() == true
    return true

  getConfig: ->
    config = for asset in @assets
      url: asset.url
      md5: asset.md5
      specificUrl: asset.specificUrl
      mimetype: asset.mimetype
      maxAge: asset.maxAge
      hash: asset.hash

  handle: (request, response, next) ->
    response.locals assets: this
    asset = @getAsset request.url
    return next() unless asset?
    response.header 'Content-Type', asset.mimetype
    if asset.maxAge?
      response.header 'Cache-Control', "public, max-age=#{asset.maxAge}"
    response.send asset.contents

  addPackage: (pack) ->
    for asset in pack
      @addAsset(asset)

  addAsset: (asset) ->
    asset.on 'error', (err)=>
      @emit 'error', err
    asset.on 'complete', ()=>
      @emit('complete') if @completed()
    @assets.push asset

  getAsset: (specificUrl) ->
    for asset in @assets
      if asset.specificUrl is specificUrl
        return asset

  pushS3: (options) ->
    async.forEachSeries @assets, (asset, next) =>
      buffer = new Buffer asset.contents
      client = knox.createClient options
      url = asset.specificUrl.slice 1, asset.specificUrl.length
      request = client.put url, {
        'Content-Length': buffer.length
        'Content-Type': asset.mimetype
      }
      request.on 'response', (response) =>
        response.setEncoding 'utf8'
        if response.statusCode is 200
          next()
        else
          message = "#{asset.url}: Bad S3 status code response #{response.statusCode}"
          @emit 'error', new Error message
      request.on 'error', (error) =>
        @emit 'error', error

      request.end buffer
    , =>
      @emit 's3-upload-complete'

  tag: (url) ->
    for asset in @assets
      return asset.tag() if url is asset.url
    throw new Error "No asset found for url: #{url}"

class exports.Asset extends EventEmitter
  mimetype: 'text/plain'
  constructor: (@options) ->
    @url = @options.url
    @hash = if @options.hash? then @options.hash else true
    @on 'newListener', (event, listener) =>
      if event is 'complete' and @completed() is true
        listener()
    @on 'complete', =>
      @completed_ = true
      @createSpecificUrl()
    @on 'error', =>
      @completed_ = false
    super()
  create: ->
    @emit 'complete'
  completed: ->
    return @completed_ == true
  tag: ->
    switch @mimetype
      when 'text/javascript'
        tag = "<script type=\"#{@mimetype}\" "
        return tag += "src=\"#{@specificUrl}\"></script>"
      when 'text/css'
        return "<link rel=\"stylesheet\" href=\"#{@specificUrl}\">"
      else
        return @specificUrl
  createSpecificUrl: ->
    @md5 = crypto.createHash('md5').update(@contents).digest 'hex'
    unless @hash
      return @specificUrl = @url
    @ext = pathutil.extname @url
    @specificUrl = "#{@url.slice(0, @url.length - @ext.length)}-#{@md5}#{@ext}"
    if @hostname?
      @specificUrl = "//#{@hostname}#{@specificUrl}"

exports.LessAsset = require('./assets/less').LessAsset
exports.BrowserifyAsset = require('./assets/browserify').BrowserifyAsset
exports.JadeAsset = require('./assets/jade').JadeAsset
exports.BladeAsset = require('./assets/blade').BladeAsset
exports.StaticAssetRack = require('./assets/static').StaticAssetRack
exports.StaticAsset = require('./assets/static').StaticAsset
exports.SnocketsAsset = require('./assets/snockets').SnocketsAsset
exports.AngularTemplatesAsset = require('./assets/angularTemplates').AngularTemplatesAsset
