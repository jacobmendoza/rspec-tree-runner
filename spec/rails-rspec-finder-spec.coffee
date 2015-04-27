Path = require 'path'
RailsRspecFinder = require '../lib/rails-rspec-finder'

describe 'RailsRspecFinder', ->
  [finder, rootFolder, finder] = []

  rootFolder = '/Users/X/Repo/project-folder'

  existsSyncSpy = jasmine.createSpy('spy')

  beforeEach ->
    atom.config.set('rspec-tree-runner.specSearchPaths', ['spec', 'fast_spec'])

    atom.config.set('rspec-tree-runner.specDefaultPath', 'spec')

    finder = new RailsRspecFinder(rootFolder, { existsSync: existsSyncSpy })

  describe 'toggleSpecFile', ->
    describe 'when supplying spec files', ->
      it 'returns application file when passing spec', ->
        result = finder.toggleSpecFile('/Users/X/Repo/project-folder/spec/some_file_spec.rb')
        expect(result).toBe rootFolder.concat('/app/some_file.rb')

    describe 'when supplying non spec files', ->
      it 'returns spec file looking in specified locations', ->
        result = finder.toggleSpecFile('/Users/X/Repo/project-folder/app/models/user.rb')
        expect(existsSyncSpy).toHaveBeenCalledWith('/Users/X/Repo/project-folder/spec/models/user_spec.rb');
        expect(existsSyncSpy).toHaveBeenCalledWith('/Users/X/Repo/project-folder/fast_spec/models/user_spec.rb');
