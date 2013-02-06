
rack = require '../lib/index'
assert = require 'assert'



describe 'AssetRack', ->
  describe '#constructor', ->
    assets = null
    it 'does not throw', (done)->
      assert.doesNotThrow ()->
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
        done()

    it 'should run', (done)->
      assets.on 'complete', ()->
        done()
      assets.once 'error', (err)->
        assets.removeAllListeners()
        done(err)

    it 'test tag', (done)->
      assert.doesNotThrow ()->
        assert.notEqual assets.tag('/style.css'), null
        assert.notEqual assets.tag('/templates.js'), null
        assert.notEqual assets.tag('/app.js'), null
        done()

  describe.skip 'push to S3', ->
    it 'should complete', (done) ->
      assets.on 'complete', ->
        aws = require '/etc/techpines/aws'
        assets.pushS3
          bucket: 'temp.techines.com'
          key: aws.key
          secret: aws.secret       
        done()

describe 'BladeAsset', ->
  describe '#constructor', ->
    asset = null
    it 'create', (done)->
      assert.doesNotThrow ()->
        asset = new rack.BladeAsset
          dirname: "#{__dirname}/fixtures/blade"
          url: '/blade.js'
        asset.create()
        done()
    
    it 'should be completed', (done)->
      asset.on 'complete', ()->
        assert.notEqual asset.contents, null
        assert.notEqual asset.specificUrl, null
        done()
      asset.once 'error', (err)->
        asset.removeAllListeners()
        done(err)

  describe 'AssetRack with BladeAsset', ()->
    it 'should run', (done)->
      assets = new rack.AssetRack [
        new rack.BladeAsset
          dirname: "#{__dirname}/badpath"
          url: '/blade.js'
      ]
      assets.on 'complete', ()->
        assert.doesNotThrow ()->
          assert.notEqual assets.tag('/blade.js'), null
        done()
      assets.once 'error', (err)->
        assets.removeAllListeners()
        done(err)

    


describe 'StaticPackAsset', ->
  describe 'Js package', ->
    asset = null
    it 'create', (done)->
      assert.doesNotThrow ()->
        asset = new rack.StaticPackAsset
          dirname: "#{__dirname}/fixtures/staticpack"
          url: '/static.js'
          type: 'js'
          compress: true
        asset.create()
        done()

    it 'should be completed', (done)->
      asset.on 'complete', ()->
        assert.equal asset.filenames.length, 2
        done()
      asset.on 'error', (err)->
        done(err)

  describe 'Css package', ->
    asset = null
    it 'create', (done)->
      assert.doesNotThrow ()->
        asset = new rack.StaticPackAsset
          basedir: "#{__dirname}/fixtures/staticpack/"
          filenames: [
            "test2.css"
            "test1.css"
            "test1.css"
          ]
          url: '/static.css'
          type: 'css'
        asset.create()
        done()

    it 'should be completed', (done)->
      asset.on 'complete', ()->
        assert.equal asset.filenames.length, 2
        done()
      asset.on 'error', (err)->
        done(err)


describe 'BrowserifyAsset', ->
  describe '#constructor', ->
    asset = null
    it 'create', (done)->
      assert.doesNotThrow ()->
        asset = new rack.BrowserifyAsset
          filename: "#{__dirname}/fixtures/coffeescript/main.coffee"
          url: '/main.js'
          watch: true
          debug: true
        asset.create()
        done()
    
    it 'should be completed', (done)->
      asset.on 'complete', ()->
        assert.notEqual asset.contents, null
        assert.notEqual asset.specificUrl, null
        done()
      asset.once 'error', (err)->
        asset.removeAllListeners()
        done(err)

    it 'should emit error', (done)->
      asset = new rack.BrowserifyAsset
        filename: "#{__dirname}/fixtures/coffeescript/error.coffee"
        url: '/main.js'
        watch: true
        debug: true
      asset.on 'error', (err)->
        assert.notEqual err, null
        done()
      asset.create()
