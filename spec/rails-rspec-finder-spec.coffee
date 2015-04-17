Path = require 'path'
RailsRspecFinder = require '../lib/rails-rspec-finder'

describe 'RailsRspecFinder', ->

  defaultSpecFolders = ['spec', 'fast_spec']
  rootFolder = '/Users/X/Repo/project-folder'
  existsSyncSpy = jasmine.createSpy('spy')
  fs = { existsSync: existsSyncSpy }
  finder = new RailsRspecFinder(rootFolder, defaultSpecFolders, 'spec', fs)

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
