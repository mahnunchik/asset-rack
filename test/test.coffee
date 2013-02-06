
rack = require '../lib/index'
assert = require 'assert'


describe 'AssetRack', ->
  describe '#constructor', ->
    assets = new rack.AssetRack [
        new rack.LessAsset
          url: '/style.css'
          filename: "#{__dirname}/fixtures/less/test.less"
          compress: true
      ,
        new rack.JadeAsset
          url: '/templates.js'
          dirname: "#{__dirname}/fixtures/jade"
          compress: true
      ,
        new rack.BrowserifyAsset
          url: '/app.js'
          filename: "#{__dirname}/fixtures/coffeescript/app.coffee"
          compress: true
      ]
    it 'should run', ->
    it 'should complete', (done) ->
      assets.on 'complete', ->
        #console.log assets
        #console.log 'cheesy dicks'
        
        aws = require '/etc/techpines/aws'
        assets.pushS3
          bucket: 'temp.techines.com'
          key: aws.key
          secret: aws.secret
        
        done()


describe 'AssetRack1', ->
  describe '#constructor', ->
    assets = new rack.AssetRack [
      new rack.BladeAsset
        dirname: "#{__dirname}/fdfdsf"
        url: '/blade.js'
    ]
    assets.on 'error', (err)->
      console.log 'assets.on', err
    it 'shoul', (done)->
      console.log 'ahaha'

describe 'BladeAsset', ->
  describe '#constructor', ->
    asset = new rack.BladeAsset
      dirname: "#{__dirname}/fixtures/blade"
      url: '/blade.js'
    asset.create()
    assert.equal asset.filenames.length, 2

    asset.on 'complete', ()->
      console.log 'asset.contents', asset
    asset.on 'error', (err)->
      console.log err

describe 'StaticPackAsset', ->
  describe 'Js package', ->
    asset = new rack.StaticPackAsset
      dirname: "#{__dirname}/fixtures/staticpack"
      url: '/static.js'
      type: 'js'
      compress: true
    asset.create()
    assert.equal asset.filenames.length, 2

    asset.on 'complete', ()->
      console.log 'asset.contents', asset.contents
    asset.on 'error', (err)->
      console.log err

  describe 'Css package', ->
    asset = new rack.StaticPackAsset
      filenames: [
        "#{__dirname}/fixtures/staticpack/test2.css"
        "#{__dirname}/fixtures/staticpack/test1.css"
      ]
      url: '/static.css'
      type: 'css'
    asset.create()
    assert.equal asset.filenames.length, 2

    asset.on 'complete', ()->
      console.log 'asset.contents', asset.contents
    asset.on 'error', (err)->
      console.log err