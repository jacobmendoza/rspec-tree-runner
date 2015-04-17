Path = require 'path'

supportedPathsReg = (paths) ->
  new RegExp("^\/(app|lib|#{paths.join('|')})\/", 'i')

specLibPathsReg = (paths) ->
  new RegExp("^\/(#{paths.join('|')})\/lib\/", 'i')

specAppPathsReg = (paths) ->
  new RegExp("^\/(#{paths.join('|')})\/", 'i')

module.exports =
class RailsRspecFinder
  constructor: (@root, @specPaths, @specDefault, @fs) ->

  toggleSpecFile: (file) ->
    relativePath = file.substring(@root.length)
    return null unless relativePath.match supportedPathsReg(@specPaths)

    if relativePath.match /_spec\.rb$/
      @getRubyFile relativePath
    else
      @findSpecFile relativePath

  getRubyFile: (path) ->
    if path.match /^\/spec\/views/i
      path = path.replace /_spec\.rb$/, ''
    else
      path = path.replace /_spec\.rb$/, '.rb'
    path = path.replace specLibPathsReg(@specPaths), '/lib/'
    path = path.replace specAppPathsReg(@specPaths), '/app/'
    Path.join @root, path

  findSpecFile: (path) ->
    for specPath in @specPaths
      file = @getSpecFile path, specPath
      return file if @fs.existsSync file
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
