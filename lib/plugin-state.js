/** @babel */
import EventEmitter from 'events';
import RSpecAnalyzerCommand from './rspec-analyzer-command';
import RSpecLauncherCommand from './rspec-launcher-command';
import TreeBuilder from './tree-builder';
import getFile from './current-file';

class PluginState extends EventEmitter {
  constructor(
    treeBuilder = new TreeBuilder(),
    rspecAnalyzerCommand = new RSpecAnalyzerCommand(),
    rspecLauncherCommand = new RSpecLauncherCommand()
  ) {
    super();
    EventEmitter.call(this);

    this.treeBuilder = treeBuilder;
    this.rspecAnalyzerCommand = rspecAnalyzerCommand;
    this.rspecLauncherCommand = rspecLauncherCommand;

    this.wireCommandsEvents();
  }
  wireCommandsEvents() {
    this.rspecAnalyzerCommand.on('onDataParsed', (dataReceived) => {
      const asTree = this.treeBuilder.buildFromStandardOutput(dataReceived);
      this.emit('onTreeBuilt', { asTree: asTree, summary: undefined, stdErrorData: undefined });
    });

    this.rspecLauncherCommand.on('onResultReceived',
      (testsResults) => this.updateTreeWithTests(testsResults.result, testsResults.stdErrorData));
  }
  set(editor) {
    if (!editor || !editor.buffer){
      this.setNullState();
      return;
    }

    this.editor = editor;
    this.file = getFile(editor.buffer.file.path);

    if (this.file.isValidSpecFile()) {
      this.analyze(this.file.path);
    }
  }
  setNullState() {
    this.file = null;
  }
  analyze(file) {
    this.emit('onSpecFileBeingAnalyzed', undefined);
    this.rspecAnalyzerCommand.run(file);
  }
  runTests() {
    if (!this.file || !this.file.isValidSpecFile()) {
      return;
    }

    this.emit('onTestsRunning', undefined);
    this.rspecLauncherCommand.run(this.file.path);
  }
  runSingleTest() {
    if (!this.file || !this.file.isValidSpecFile()) {
      return;
    }

    this.cursor = this.editor.cursors[0];
    const specRowToAnalyze = this.cursor.getBufferRow() + 1;

    this.emit('onTestsRunning', undefined);
    this.rspecLauncherCommand.run(this.file.path + ':' + specRowToAnalyze);
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
