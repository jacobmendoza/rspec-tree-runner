/** @babel */
class StateBuilder {
	buildDefault() {
		this._internalState = {
			file: {
				name: '',
				isSpecFile: () => false,
				isRubyFile: () => false
			},
			asTree: [],
			rspecExecutionWarning: undefined,
			rspecExecutionError: undefined,
			parsingSpecError: undefined,
			summary: undefined
		};
		return this._internalState;
	}

	build() {
		return this._internalState;
	}

	from(state) {
		this._internalState.rspecExecutionWarning = undefined;
		this._internalState.rspecExecutionError = undefined;
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

	withRSpecExecutionWarning(stdErrData) {
		this._internalState.rspecExecutionWarning = stdErrData;
		return this;
	}

	withRSpecExecutionError(stdErrData) {
		this._internalState.rspecExecutionError = stdErrData;
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
