/** @babel */
module.exports = class AstParser {
  parse(data) {
    if (!data) {
      return [];
    }

    const tree = [];
    const jsonObject = JSON.parse(data);
    this.addChildren(tree, jsonObject);
    return tree;
  }
  addChildren(result, currentOld) {
    const types = ['describe', 'context', 'it', 'feature', 'scenario'];

    let newNode;
    if (types.includes(currentOld.type)) {
      newNode = {
          type: currentOld.type,
          text: currentOld.identifier,
          line: currentOld.line,
          status: undefined,
          withReport: undefined,
          children: []
        };

      result.push(newNode);

      if (!currentOld.children) {
        return;
      }
    }

    for (let child of currentOld.children) {
      const nextSubTree = (newNode == undefined) ? result : newNode.children;
      this.addChildren(nextSubTree, child);
    }
  }
};
