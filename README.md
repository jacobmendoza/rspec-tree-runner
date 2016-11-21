[![Build Status](https://travis-ci.org/jacobmendoza/rspec-tree-runner.svg?branch=master)](https://travis-ci.org/jacobmendoza/rspec-tree-runner)
# rspec-tree-runner for Atom

RSpec-tree-runner is a complete test runner for RSpec integrated in Atom.

<img src="http://jacobmendoza.github.io/rspec-tree-runner/demo.gif?1" width="854" loop=infinite>

This package finds the corresponding tests for your file, displaying the hierarchical structure and allowing you to run them, integrating the results in the editor.

## How to use it
HotKeys:
- __Ctrl+Alt+L__ - Activate the package
- __Ctrl+Alt+X__ - Executes all test
- __Ctrl+Alt+R__ - Executes single test (current line)

To activate the package press ctrl-alt-l.

## Important note about this version

In previous versions and trying to promote the TDD flow, the package used to allow toggling between the test file and the file that hosts the production code, following the Rails convention. That convention dictates the folders where the files should be located.

That feature, coupled the package with Rails, confusing users working in projects that were not using that structure. The feature has been removed simplifying not only the use but also the codebase.

## How does it work?

rspec-tree-runner relies on Ripper, a Ruby script parser. In this case, we use it to read the spec file and convert it into a symbolic expression tree (a binary tree). When you open a spec file, rspec-tree-runner calls a small Ruby script that generates the expression, and transforms it to a different kind of tree, easier to process in Atom and that contains information specific to a spec file (the kind of block, the line number, the identifier, etc) as opposed to the output of Ripper, which is general to any Ruby script.

When executing the tests, the package calls the RSpec test runner using the json formatter, because it makes easier processing the results. The RSpec test runner, after executing the file, returns all the tests, with the status (passed, failed or pending) and the line of the test that has been executed.

![alt tag](https://raw.github.com/jacobmendoza/rspec-tree-runner/master/process.png)

We match all this information with the tree that we built before, using the line number as the identifier for the node.

## Big thanks to…
This package wouldn't have been possible without the help of the [Atom Discussion](https://discuss.atom.io/) colleagues. Also the following plugins and authors have been a big inspiration, and their code has been an important help:

- [atom-rspec](https://github.com/fcoury/atom-rspec) by Felipe Coury
- [atom-rails-rspec](https://github.com/wangyuhere/atom-rails-rspec) by Yu Wang
- [atom-spec-tree-view](https://github.com/hokaccha/atom-spec-tree-view) by Kazuhito Hokamura

## Contributors

- Thanks to José Morais ([@jmorais](https://github.com/jmorais)) who kindly provided the feature that allow users to run a single test.
