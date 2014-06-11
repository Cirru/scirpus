#!/usr/bin/env coffee
project = 'repo/scirpus'

require 'shelljs/make'
path = require 'path'
mission = require 'mission'

mission.time()

target.test = ->
  compiler = require './coffee/compiler'
  compiler.compile
    from: 'scirpus/cirru/demo.cirru'
    to: 'scirpus/js'
    base: '../'

target.coffee = ->
  mission.coffee
    find: /\.coffee$/, from: 'coffee/', to: 'js/', extname: '.js'
    options:
      bare: yes

cirru = (data) ->
  mission.cirruHtml
    file: 'index.cirru'
    from: 'template/'
    to: './'
    extname: '.html'
    data: data

target.cirru = -> cirru inDev: yes
target.cirruBuild = -> cirru inBuild: yes

target.dev = ->
  cirru inDev: yes
  target.coffee yes

target.build = ->
  cirru inBuild: yes
  target.coffee yes

target.watch = ->
  station = mission.reload()

  mission.watch
    files: ['cirru/', 'coffee/']
    trigger: (filepath, extname) ->
      switch extname
        when '.cirru'
          cirru inDev: yes
          station.reload project
        when '.coffee'
          filepath = path.relative 'coffee/', filepath
          mission.coffee
            file: filepath, from: 'coffee/', to: 'js/', extname: '.js'
            options:
              bare: yes

target.patch = ->
  mission.bump
    file: 'package.json'
    options:
      at: 'patch'

target.rsync = ->
  mission.rsync
    file: './'
    dest: 'tiye:~/repo/cirru/scirpus'
    options:
      exclude: [
        'node_modules/'
        'bower_components/'
        'coffee'
        'README.md'
        'js'
        '.git/'
      ]