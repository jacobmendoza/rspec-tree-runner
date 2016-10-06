/** @babel */

class StateBuilder {
  buildDefault() {
    this._internalState = {
      file: {
        name:'',
        isSpecFile: () => false,
        isRubyFile: () => false
      },
      asTree: [],
      stdErrorData: undefined,
      summary: undefined,
      parsingSpecError: undefined
    };
    return this._internalState;
  }

  build() {
    return this._internalState;
  }

  from(state) {
    this._internalState.parsingSpecError = undefined;
    this._internalState = Object.assign({}, state);
    return this;
  }

  withFile(file) {
    this._internalState.file = file;
    return this;
  }

  withAsTree(asTree) {
    this._internalState.asTree = asTree;
    return this;
  }

  withSpecParsingError(stdErrData) {
    this._internalState.parsingSpecError = stdErrData;
    return this;
  }

  withStdErrorData(stdErrorData) {
    this._internalState.stdErrorData = stdErrorData || '';
    return this;
  }

  withSummary(summary) {
    this._internalState.summary = summary;
    return this;
  }

  loading(value) {
    this._internalState.loading = value;
    return this;
  }
}

module.exports = StateBuilder;
