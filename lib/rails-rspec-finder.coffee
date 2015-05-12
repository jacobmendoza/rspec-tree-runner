Path = require 'path'

rootPathReg = ->
  new RegExp('^\/[\\w,\\s-]+(\\.[A-Za-z]+)*$', 'i')

supportedPathsReg = (paths) ->
  new RegExp("^\/(app|lib|src|#{paths.join('|')})\/", 'i')

specLibPathsReg = (paths) ->
  new RegExp("^\/(#{paths.join('|')})\/lib\/", 'i')

specAppPathsReg = (paths) ->
  new RegExp("^\/(#{paths.join('|')})\/", 'i')

module.exports =
class RailsRSpecFinder
  constructor: (@root = atom.project.getPaths()[0], fileSystem = fs) ->
    @fs = fileSystem
    @specPaths = atom.config.get('rspec-tree-runner.specSearchPaths')
    @specDefault = atom.config.get('rspec-tree-runner.specDefaultPath')

  toggleSpecFile: (file) ->
    relativePath = @getFileWithoutProjectRoot(file)

    specPathsMatch = relativePath.match supportedPathsReg(@specPaths)

    rootMatch =  rootPathReg().test(relativePath)

    return null unless specPathsMatch or rootMatch

    if @isSpec(relativePath)
      @getRubyFile relativePath
    else
      @findSpecFile relativePath

  getFileWithoutProjectRoot: (file) ->
    file.substring(@root.length)

  isSpec: (relativePath) ->
    relativePath.match /_spec\.rb$/

  getRubyFile: (path) ->
    if path.match /^\/spec\/views/i
      path = path.replace /_spec\.rb$/, ''
    else
      path = path.replace /_spec\.rb$/, '.rb'
    path = path.replace specLibPathsReg(@specPaths), '/lib/'
    path = path.replace specAppPathsReg(@specPaths), '/app/'
    Path.join @root, path

  fileExists: (file) ->
    @fs.existsSync file

  findSpecFile: (path) ->
    for specPath in @specPaths
      file = @getSpecFile path, specPath
      return file if @fileExists file
    @getSpecFile path, @specDefault

  getSpecFile: (path, specPath) ->
    if path.match /\.rb$/
      path = path.replace /\.rb$/, '_spec.rb'
    else
      path = path + '_spec.rb'

    if path.match /^\/app\//
      newPath = path.replace /^\/app\//, "/#{specPath}/"
    else
      newPath = path.replace /^\/lib\//, "/#{specPath}/lib/"
    Path.join @root, newPath
