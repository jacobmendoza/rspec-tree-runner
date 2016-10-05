PluginStateStore = require '../lib/plugin-state-store'
TreeBuilder = require '../lib/tree-builder'
RSpecAnalyzerCommand = require '../lib/rspec-analyzer-command'
RSpecLauncherCommand = require '../lib/rspec-launcher-command'

describe 'PluginState', ->
  [state, rspecAnalyzerCommand, specCommandLauncher] = []
  defaultSpecFolders = ['spec', 'fast_spec']
  rootFolder = '/Users/X/Repo/project-folder'

  beforeEach ->
    rspecAnalyzerCommand = new RSpecAnalyzerCommand

    specCommandLauncher = new RSpecLauncherCommand

    treeBuilder = new TreeBuilder

    spyOn(rspecAnalyzerCommand, 'run')

    spyOn(specCommandLauncher, 'run')

    atom.config.set('rspec-tree-runner.specDefaultPath', 'spec')

    atom.config.set('rspec-tree-runner.specSearchPaths', ['spec', 'fast_spec'])

    state = new PluginStateStore(treeBuilder, rspecAnalyzerCommand, specCommandLauncher)

  describe 'When no editor available', ->
    beforeEach ->
      state.set(null)
      state.runTests()

    xit 'sets null state', ->
      expect(state.file).toBeNull()

    xit 'does not run tests', ->
      expect(specCommandLauncher.run).not.toHaveBeenCalled()

  describe 'When no buffer available', ->
    beforeEach ->
      state.set({buffer: null})
      state.runTests

    xit 'sets null state', ->
      expect(state.file).toBeNull()

    xit 'does not run tests', ->
      expect(specCommandLauncher.run).not.toHaveBeenCalled()

  describe 'When spec file is supplied', ->
    specFile = '/Users/X/Repo/project-folder/spec/some_file_spec.rb'
    editor = {
      buffer: { file: { path: specFile } },
      cursors: [{}]
    }

    beforeEach ->
      state.set(editor)
      state.runTests()

    xit 'sets a correct state', ->
      expect(state.file.path).toBe(specFile)
      expect(state.file.isValidSpecFile()).toBe(true)
      expect(rspecAnalyzerCommand.run).toHaveBeenCalledWith(specFile)

    xit 'runs the analyze command', ->
      expect(rspecAnalyzerCommand.run).toHaveBeenCalledWith(specFile)

    xit 'runs tests over the correct file', ->
      expect(specCommandLauncher.run).toHaveBeenCalledWith(specFile)

  describe 'When normal file is supplied', ->
    normalFile = '/Users/X/Repo/project-folder/app/some_file.rb'
    editor = {
      buffer: { file: { path: normalFile } },
      cursors: [{}]
    }

    describe 'If file exists', ->
      beforeEach ->
        state.set(editor)
        state.runTests()

      xit 'sets a correct state', ->
        expect(state.file.path).toBe(normalFile)
        expect(state.file.isValidSpecFile()).toBe(false)

      xit 'runs tests over the correct file', ->
        expect(specCommandLauncher.run).not.toHaveBeenCalled()
