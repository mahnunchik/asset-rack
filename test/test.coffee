
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

    


