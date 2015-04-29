PluginState = require '../lib/plugin-state'
RailsRSpecFinder = require '../lib/rails-rspec-finder'
RSpecAnalyzerCommand = require '../lib/rspec-analyzer-command'
RSpecLauncherCommand = require '../lib/rspec-launcher-command'

describe 'PluginState', ->
  [railsRSpecFinder, state, rspecAnalyzerCommand, specCommandLauncher, fs, emitter] = []
  defaultSpecFolders = ['spec', 'fast_spec']
  rootFolder = '/Users/X/Repo/project-folder'

  beforeEach ->
    emitter = {}

    fs = { existsSync: -> true }

    rspecAnalyzerCommand = new RSpecAnalyzerCommand

    specCommandLauncher = new RSpecLauncherCommand

    spyOn(rspecAnalyzerCommand, 'run')

    spyOn(specCommandLauncher, 'run')

    spyOn(specCommandLauncher, 'onResultReceived')

    atom.config.set('rspec-tree-runner.specDefaultPath', 'spec')

    atom.config.set('rspec-tree-runner.specSearchPaths', ['spec', 'fast_spec'])

    railsRSpecFinder = new RailsRSpecFinder(rootFolder, fs)

    state = new PluginState(
      emitter, railsRSpecFinder, rspecAnalyzerCommand, specCommandLauncher)

  describe 'When no editor available', ->
    beforeEach ->
      state.set(null)
      state.runTests()

    it 'sets null state', ->
      expect(state.currentFilePath).toBeNull()
      expect(state.currentCorrespondingFilePath).toBeNull()
      expect(state.specFileToAnalyze).toBeNull()
      expect(state.specFileExists).toBeNull()

    it 'does not run tests', ->
      expect(specCommandLauncher.run).not.toHaveBeenCalled()

  describe 'When no buffer available', ->
    beforeEach ->
      state.set({buffer: null})
      state.runTests

    it 'sets null state', ->
      expect(state.currentFilePath).toBeNull()
      expect(state.currentCorrespondingFilePath).toBeNull()
      expect(state.specFileToAnalyze).toBeNull()
      expect(state.specFileExists).toBeNull()

    it 'does not run tests', ->
      expect(specCommandLauncher.run).not.toHaveBeenCalled()

  describe 'When spec file is supplied', ->
    specFile = '/Users/X/Repo/project-folder/spec/some_file_spec.rb'
    correspondingFile = '/Users/X/Repo/project-folder/app/some_file.rb'
    editor = { buffer: { file: { path: specFile } } }

    beforeEach ->
      state.set(editor)
      state.runTests()

    it 'sets a correct state', ->
      expect(state.currentFilePath).toBe(specFile)
      expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
      expect(state.specFileToAnalyze).toBe(specFile)
      expect(state.specFileExists).toBe(true)
      expect(rspecAnalyzerCommand.run).toHaveBeenCalledWith(specFile)

    it 'runs tests over the correct file', ->
      expect(specCommandLauncher.run).toHaveBeenCalledWith(specFile)

  describe 'When normal file is supplied', ->
    normalFile = '/Users/X/Repo/project-folder/app/some_file.rb'
    correspondingFile = '/Users/X/Repo/project-folder/spec/some_file_spec.rb'
    editor = { buffer: { file: { path: normalFile } } }

    describe 'If file exists', ->
      beforeEach ->
        state.set(editor)
        state.runTests()

      it 'runs the command', ->
        expect(rspecAnalyzerCommand.run).toHaveBeenCalledWith(correspondingFile)

      it 'sets a correct state', ->
        expect(state.currentFilePath).toBe(normalFile)
        expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
        expect(state.specFileToAnalyze).toBe(correspondingFile)
        expect(state.specFileExists).toBe(true)

      it 'runs tests over the correct file', ->
        expect(specCommandLauncher.run).toHaveBeenCalledWith(correspondingFile)

    describe 'If file does not exist', ->
      beforeEach ->
        fs = { existsSync: -> false }
        railsRSpecFinder = new RailsRSpecFinder(rootFolder, fs)
        state = new PluginState(emitter, railsRSpecFinder, rspecAnalyzerCommand, specCommandLauncher)
        state.set(editor)
        state.runTests()

      it 'does not run the command analysis', ->
        expect(rspecAnalyzerCommand.run).not.toHaveBeenCalledWith(correspondingFile)

      it 'sets a correct state', ->
        expect(state.currentFilePath).toBe(normalFile)
        expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
        expect(state.specFileToAnalyze).toBe(correspondingFile)
        expect(state.specFileExists).toBe(false)

      it 'does not run tests', ->
        expect(specCommandLauncher.run).not.toHaveBeenCalled()
