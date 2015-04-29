PluginState = require '../lib/plugin-state'
RailsRSpecFinder = require '../lib/rails-rspec-finder'

describe 'PluginState', ->
  [railsRSpecFinder, state, rspecAnalyzerCommand, fs, emitter] = []
  defaultSpecFolders = ['spec', 'fast_spec']
  rootFolder = '/Users/X/Repo/project-folder'

  beforeEach ->
    emitter = {}

    fs = { existsSync: -> true }

    rspecAnalyzerCommand = {
      run: (file) -> true
      onDataParsed: (asTree) -> []
    }

    spyOn(rspecAnalyzerCommand, 'run')

    atom.config.set('rspec-tree-runner.specDefaultPath', 'spec')

    atom.config.set('rspec-tree-runner.specSearchPaths', ['spec', 'fast_spec'])

    railsRSpecFinder = new RailsRSpecFinder(rootFolder, fs)

    state = new PluginState(
      emitter, railsRSpecFinder, rspecAnalyzerCommand)

  describe 'When no editor available', ->
    it 'sets null state', ->
      state.set(null)
      expect(state.currentFilePath).toBeNull()
      expect(state.currentCorrespondingFilePath).toBeNull()
      expect(state.specFileToAnalyze).toBeNull()
      expect(state.specFileExists).toBeNull()

  describe 'When no buffer available', ->
    it 'sets null state', ->
      state.set({buffer: null})
      expect(state.currentFilePath).toBeNull()
      expect(state.currentCorrespondingFilePath).toBeNull()
      expect(state.specFileToAnalyze).toBeNull()
      expect(state.specFileExists).toBeNull()

  describe 'When spec file is supplied', ->
    it 'sets a correct state', ->
      specFile = '/Users/X/Repo/project-folder/spec/some_file_spec.rb'
      correspondingFile = '/Users/X/Repo/project-folder/app/some_file.rb'

      editor = { buffer: { file: { path: specFile } } }

      state.set(editor)
      expect(state.currentFilePath).toBe(specFile)
      expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
      expect(state.specFileToAnalyze).toBe(specFile)
      expect(state.specFileExists).toBe(true)
      expect(rspecAnalyzerCommand.run).toHaveBeenCalledWith(specFile)

  describe 'When normal file is supplied', ->
    normalFile = '/Users/X/Repo/project-folder/app/some_file.rb'
    correspondingFile = '/Users/X/Repo/project-folder/spec/some_file_spec.rb'
    editor = { buffer: { file: { path: normalFile } } }

    describe 'If file exists', ->
      beforeEach ->
        state.set(editor)

      it 'runs the command', ->
        expect(rspecAnalyzerCommand.run).toHaveBeenCalledWith(correspondingFile)

      it 'sets a correct state', ->
        expect(state.currentFilePath).toBe(normalFile)
        expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
        expect(state.specFileToAnalyze).toBe(correspondingFile)
        expect(state.specFileExists).toBe(true)

    describe 'If file does not exist', ->
      beforeEach ->
        fs = { existsSync: -> false }
        railsRSpecFinder = new RailsRSpecFinder(rootFolder, fs)
        state = new PluginState(emitter, railsRSpecFinder, rspecAnalyzerCommand)
        state.set(editor)

      it 'does not run the command', ->
        expect(rspecAnalyzerCommand.run).not.toHaveBeenCalledWith(correspondingFile)

      it 'sets a correct state', ->
        expect(state.currentFilePath).toBe(normalFile)
        expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
        expect(state.specFileToAnalyze).toBe(correspondingFile)
        expect(state.specFileExists).toBe(false)
