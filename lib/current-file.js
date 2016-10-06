/** @babel */
module.exports = (filePath) => {
  return {
    path: filePath,
    extension: filePath.split('.').pop(),
    name: filePath.split('/').pop(),
    isRubyFile() {
      return this.path && this.path.endsWith('.rb');
    },
    isSpecFile() {
      return this.path && this.path.endsWith('_spec.rb');
    }
  };
};
