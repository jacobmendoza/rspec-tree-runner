# rspec-tree-runner for Atom
## Introduction
RSpec-tree-runner is a package for Atom that aims to be a complete test runner for Atom and RSpec.

![screen cast](http://jacobmendoza.github.io/rspec-tree-runner/demo.gif)

This package finds the corresponding tests for your file, displaying the hierarchical structure and allowing you to run them, integrating the results in the editor.

**Important note: This is an early preview, and some features can fail**. The test environment has been OSX. Please, do not hesitate to report bugs and issues. I'll respond as soon as possible.

## How to use it
HotKeys:
- __Ctrl+Alt+L__ - Activate the package
- __Ctrl+Alt+X__ - Executes test
- __Ctrl+Alt+Q__ - Toggles between files and tests

To activate the package press ctrl-alt-l.

When navigating between files, the package will try to find the spec that corresponds to the current file (the package will look for them in spec and fast_spec folders. This folders can be properly modified in the package configuration). If the spec file is found, the hierarchical structure will be shown. When pressing ctrl-alt-x, RSpec runner will be called and the results will be parsed and shown in the tree.

## Important note
This software is the first time of too many things. I'm not an expert in almost any of the technologies that are used in this package and although I expect everything to be functional, the project could have important weaknesses and inconsistencies.

I would really love to hear feedback about the features or the code, and I really mean it, no matter if it's something big or just a subtle detail. This feedback, would be an important opportunity to learn. The are several areas that will probably need significant improvement:

* Non idiomatic CoffeeScript code, underuse of the features of the language.
* Poor knowledge of Atom API. Features using more complex code than required.
* Too complicated LESS code.
* Areas without appropiate tests.
* Design issues.

## Big thanks to…
This package wouldn't have been possible without the help of the [Atom Discussion](https://discuss.atom.io/) mates. Also the following plugins and authors have been a big inspiration, and their code has been an important help:

- [atom-rspec](https://github.com/fcoury/atom-rspec) by Felipe Coury
- [atom-rails-rspec](https://github.com/wangyuhere/atom-rails-rspec) by Yu Wang
- [atom-spec-tree-view](https://github.com/hokaccha/atom-spec-tree-view) by Kazuhito Hokamura
