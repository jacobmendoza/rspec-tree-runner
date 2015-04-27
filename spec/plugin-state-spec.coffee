PluginState = require '../lib/plugin-state'
RailsRSpecFinder = require '../lib/rails-rspec-finder'

describe 'PluginState', ->
  [railsRSpecFinder, state] = []
  defaultSpecFolders = ['spec', 'fast_spec']
  rootFolder = '/Users/X/Repo/project-folder'
  fs = { existsSync: -> true }

  beforeEach ->
    emitter = {}
    
    rspecAnalyzerCommand = {
      run: (file) -> true
      onDataParsed: (asTree) -> []
    }

    railsRSpecFinder = new RailsRSpecFinder(
      rootFolder,
      defaultSpecFolders,
      'spec',
      fs)

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

      editor = {
        buffer: {
          file: {
            path: specFile } } }

      state.set(editor)
      expect(state.currentFilePath).toBe(specFile)
      expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
      expect(state.specFileToAnalyze).toBe(specFile)
      expect(state.specFileExists).toBe(true)

  describe 'When normal file is supplied', ->
    it 'sets a correct state', ->
      normalFile = '/Users/X/Repo/project-folder/app/some_file.rb'
      correspondingFile = '/Users/X/Repo/project-folder/spec/some_file_spec.rb'

      editor = {
        buffer: {
          file: {
            path: normalFile } } }

      state.set(editor)
      expect(state.currentFilePath).toBe(normalFile)
      expect(state.currentCorrespondingFilePath).toBe(correspondingFile)
      expect(state.specFileToAnalyze).toBe(correspondingFile)
      expect(state.specFileExists).toBe(true)
