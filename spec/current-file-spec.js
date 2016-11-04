/** @babel */
import getFile from '../lib/current-file';

describe('CurrentFile', () => {
	it('correctly parses a filePath of a non ruby file', () => {
		const file = getFile('/some/path/something_else.txt');

		expect(file.path).toBe('/some/path/something_else.txt');
		expect(file.extension).toBe('txt');
		expect(file.name).toBe('something_else.txt');
		expect(file.isSpecFile()).toBeFalsy();
		expect(file.isRubyFile()).toBeFalsy();
	});

	it('correctly parses a filePath of a ruby file', () => {
		const file = getFile('/some/path/with_a_ruby_file.rb');

		expect(file.path).toBe('/some/path/with_a_ruby_file.rb');
		expect(file.extension).toBe('rb');
		expect(file.name).toBe('with_a_ruby_file.rb');
		expect(file.isSpecFile()).toBeFalsy();
		expect(file.isRubyFile()).toBeTruthy();
	});

	it('correctly parses a filePath of a spec file', () => {
		const file = getFile('/some/path/with_a_ruby_file_spec.rb');

		expect(file.path).toBe('/some/path/with_a_ruby_file_spec.rb');
		expect(file.extension).toBe('rb');
		expect(file.name).toBe('with_a_ruby_file_spec.rb');
		expect(file.isSpecFile()).toBeTruthy();
		expect(file.isRubyFile()).toBeTruthy();
	});
});
