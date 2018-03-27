/** @babel */
import AstParser from './ast-parser';

class TreeBuilder {
	constructor(astParser = new AstParser()) {
		this.astParser = astParser;
	}

	buildFromStandardOutput(standardOutput) {
		if (!standardOutput) {
			return {};
		}

		try {
			this.asTree = this.astParser.parse(standardOutput);
			return this.asTree;
		} catch (err) {
			atom.notifications.addError('Can\'t parse this RSpec file. Please check errors.');
			return {};
		}
	}

	updateWithTests(results) {
		const shouldUpdateTree = results && results.examples && this.asTree.length > 0;

		if (shouldUpdateTree) {
			this.updateNode(this.asTree[0], results);
		}

		return this.asTree;
	}

	updateNode(node, testsResults) {
		for (const child of node.children) {
			this.updateNode(child, testsResults);
		}

		if (node.type === 'it' && node.line) {
			node.status = 'undefined';
			for (const example of testsResults.examples) {
				if (example.line_number === node.line) {
					this.updateLeafNode(node, example);
					break;
				}
			}
		} else {
			let finalStatus = 'undefined';

			for (const child of node.children) {
				if (child.status === 'failed') {
					finalStatus = 'failed';
					break;
				} else if (child.status === 'passed' && finalStatus === 'undefined') {
					finalStatus = 'passed';
				}
			}

			node.status = finalStatus;
		}
	}

	updateLeafNode(node, example) {
		node.exception = example.exception;
		node.status = example.status;
		node.withReport = (example.status === 'failed') ? 'with-report' : '';
	}
}

export default TreeBuilder;
