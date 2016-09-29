/** @babel */
import EventEmitter from 'events';
import RSpecAnalyzerCommand from './rspec-analyzer-command';
import RSpecLauncherCommand from './rspec-launcher-command';
import TreeBuilder from './tree-builder';

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
  }
  set(editor) {
    if (!editor || !editor.buffer){
      this.setNullState();
      return;
    }

    this.editor = editor;

    const filePath = editor.buffer.file.path;
    this.file = {
      path: filePath,
      extension: filePath.split('.').pop(),
      name: filePath.split('/').pop(),
      isValidSpecFile() {
        return this.path && this.path.endsWith('_spec.rb');
      }
    };

    if (this.file.isValidSpecFile()) {
      this.analyze(this.file.path);
      this.rspecAnalyzerCommand.on('onDataParsed', (dataReceived) => {
        const asTree = this.treeBuilder.buildFromStandardOutput(dataReceived);
        this.emit('onTreeBuilt', { asTree: asTree, summary: undefined, stdErrorData: undefined });
      });

      this.rspecLauncherCommand.on('onResultReceived',
        (testsResults) => this.updateTreeWithTests(testsResults.result, testsResults.stdErrorData));
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
