/** @babel */
import EventEmitter from 'events';
import ChildProcess from 'child_process';

class TerminalCommandRunner extends EventEmitter {
	constructor() {
		super();
		EventEmitter.call(this);

		this.clean();
	}

	run(command, destinyFolder = null) {
		const spawn = ChildProcess.spawn;

		const terminal = spawn('bash', ['-l']);
		terminal.on('close', this.onClose.bind(this));
		terminal.stdout.on('data', this.onStdOut.bind(this));
		terminal.stderr.on('data', this.onStdErr.bind(this));

		const terminalCommand = (destinyFolder) ?
			`cd "${destinyFolder}" && ${command}\n` :
			`${command}\n`;

		console.log(`Launching command to terminal: ${terminalCommand}`);

		terminal.stdin.write(terminalCommand);
		terminal.stdin.write('exit\n');
	}

	clean() {
		this.stdOutData = '';
		this.stdErrorData = '';
	}

	onStdOut(newData) {
		this.stdOutData = this.stdOutData.concat(newData.toString());
		this.emit('onStdOutData', this.stdOutData);
	}

	onStdErr(newData) {
		this.stdErrorData = this.stdErrorData.concat(newData.toString());
		this.emit('onData', this.stdErrorData);
	}

	onClose() {
		this.emit('finishData', {stdOutData: this.stdOutData, stdErrData: this.stdErrorData});
	}
}

export default TerminalCommandRunner;
