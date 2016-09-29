/** @babel */
module.exports = (filePath) => {
  return {
    path: filePath,
    extension: filePath.split('.').pop(),
    name: filePath.split('/').pop(),
    isValidSpecFile() {
      return this.path && this.path.endsWith('_spec.rb');
    }
  };
};
