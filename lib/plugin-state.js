/** @babel */
import EventEmitter from 'events';
import RailsRSpecFinder from './rails-rspec-finder';
import RSpecAnalyzerCommand from './rspec-analyzer-command';
import RSpecLauncherCommand from './rspec-launcher-command';
import TreeBuilder from './tree-builder';

class PluginState extends EventEmitter {
  constructor(
    treeBuilder = new TreeBuilder(),
    railsRSpecFinder = new RailsRSpecFinder(),
    rspecAnalyzerCommand = new RSpecAnalyzerCommand(),
    rspecLauncherCommand = new RSpecLauncherCommand()
  ) {
    super();
    EventEmitter.call(this);

    this.treeBuilder = treeBuilder;
    this.railsRSpecFinder = railsRSpecFinder;
    this.rspecAnalyzerCommand = rspecAnalyzerCommand;
    this.rspecLauncherCommand = rspecLauncherCommand;
  }
  set(editor) {
    if (!editor || !editor.buffer){
      this.setNullState();
      return;
    }

    this.cursor = editor.cursors[0];
    this.currentFilePath = editor.buffer.file.path;
    this.currentFilePathExtension = this.currentFilePath.split('.').pop();

    const isNavigatingToCorresponding = (this.prevCorrespondingFilePath) && (this.prevCorrespondingFilePath === this.currentFilePath);

    this.currentCorrespondingFilePath = this.railsRSpecFinder.toggleSpecFile(this.currentFilePath);
    this.prevCorrespondingFilePath = this.currentCorrespondingFilePath;

    if (!this.currentCorrespondingFilePath) {
      this.setNullState();
      return;
    }

    this.specFileToAnalyze = this._getSpecToAnalyze();
    this.currentFileName = this.specFileToAnalyze.split('/').pop();
    this.specFileExists = this.railsRSpecFinder.fileExists(this.specFileToAnalyze);

    if (this.specFileToAnalyze) {
        this.specFileToAnalyzeWithoutProjectRoot = this.railsRSpecFinder.getFileWithoutProjectRoot(this.specFileToAnalyze);
    }

    const shouldAnalyze = (this.specFileToAnalyze && this.specFileExists && !isNavigatingToCorresponding);

    if (shouldAnalyze) {
      this.analyze(this.specFileToAnalyze);
    }

    this.rspecAnalyzerCommand.on('onDataParsed', (dataReceived) => {
      const asTree = this.treeBuilder.buildFromStandardOutput(dataReceived);
      this.emit('onTreeBuilt', { asTree: asTree, summary: undefined, stdErrorData: undefined });
    });

    this.rspecLauncherCommand.on('onResultReceived',
      (testsResults) => this.updateTreeWithTests(testsResults.result, testsResults.stdErrorData));
  }
  _getSpecToAnalyze() {
    if (this.railsRSpecFinder.isSpec(this.currentFilePath)) {
      return this.currentFilePath;
    } else {
      return this.currentCorrespondingFilePath;
    }
  }
  setNullState() {
    this.currentFilePath = null;
    this.currentCorrespondingFilePath = null;
    this.specFileToAnalyze = null;
    this.specRowToAnalyze = null;
    this.specFileExists = null;
    this.specFileToAnalyzeWithoutProjectRoot = null;
  }
  analyze(file) {
    this.emit('onSpecFileBeingAnalyzed', undefined);
    this.rspecAnalyzerCommand.run(file);
  }
  runTests() {
    if (!this.specFileToAnalyze || !this.specFileExists) {
      return;
    }

    this.emit('onTestsRunning', undefined);
    this.rspecLauncherCommand.run(this.specFileToAnalyze);
  }
  runSingleTest() {
    if (!this.specFileToAnalyze || !this.specFileExists) {
      return;
    }

    this.specRowToAnalyze = this.cursor.getBufferRow() + 1;

    this.emit('onTestsRunning', undefined);
    this.rspecLauncherCommand.run(this.specFileToAnalyze + ':' + this.specRowToAnalyze);
  }
  updateTreeWithTests(results, stdErrorData) {
    const asTree = this.treeBuilder.updateWithTests(results);
    this.emit('onTreeBuilt', {
      asTree: asTree,
      summary: results ? results.summary || undefined : undefined,
      stdErrorData: stdErrorData || ''
    });
  }
}

module.exports = PluginState;
