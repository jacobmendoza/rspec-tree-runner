require 'json'
require 'ripper'

module SpecAnalyzer
  # Class that identifies a node
  class Node
    attr_accessor :identifier, :children, :line, :type
    def initialize(identifier)
      @identifier = identifier
    end

    def add_child(node)
      @children = [] if @children.nil?
      @children << node
    end

    def try_assign_from(expression, exploration_state)
      try_assign_identifier(expression, exploration_state)

      try_assign_type(expression, exploration_state)

      try_assign_line(expression, exploration_state)
    end

    def to_s
      "#{@identifier} with #{@children.length} children"
    end

    def to_hash
      hash = {
        type: @type.to_s, identifier: @identifier,
        line: @line, children: []
      }

      return hash if @children.nil?

      @children.each do |child|
        child_hash = child.to_hash
        hash[:children] << child_hash
      end

      hash
    end

    private

    def try_assign_identifier(expression, exploration_state)
      @identifier = expression if expression.is_a?(String) && exploration_state.assign_identifier?
    end

    def try_assign_type(expression, exploration_state)
      @type = expression if @type.nil? && expression.is_a?(String) && exploration_state.assign_type?
    end

    def try_assign_line(expression, exploration_state)
      return unless expression.is_a?(Integer)
      @line = expression if @line.nil? && exploration_state.assign_type?
    end
  end

  # Class that represents the current state of the recursion
  class ExplorationState
    attr_accessor :adding_block_context, :adding_identifier
    def initialize(adding_block_context, adding_identifier)
      @adding_block_context = adding_block_context
      @adding_identifier = adding_identifier
    end

    def assign_identifier?
      @adding_block_context && !@adding_identifier
    end

    def assign_type?
      @adding_block_context && @adding_identifier
    end
  end

  # Class the implements the parsing of the file
  class Parser
    def parse_file(file_name)
      file = File.read(file_name)

      result = Ripper.sexp_raw(file)

      root = Node.new('root')

      explore(result, root, ExplorationState.new(false, false))

      root
    end

    private

    def explore(s_expression, current_node, exploration_state)
      s_expression.each do |expression|
        if expression.is_a?(Array)
          explore(expression, current_node,
                  ExplorationState.new(exploration_state.adding_block_context, exploration_state.adding_identifier))
        else
          if expression == :method_add_block
            child = Node.new('temporary')
            current_node.add_child(child)
            current_node = child
            exploration_state.adding_block_context = true
            exploration_state.adding_identifier = false
          end

          write_node_and_modify_state expression, exploration_state, current_node
        end
      end
    end

    def write_node_and_modify_state(expression, exploration_state, current_node)
      exploration_state.adding_block_context = false if expression == :do_block

      exploration_state.adding_identifier = true if expression == :@ident

      current_node.try_assign_from(expression, exploration_state)
    end
  end
end

error_message = 'spec-analyzer-script needs file supplied as parameter (ex: ruby spec-analyzer-script FILE)'

if ARGV.length == 0
  STDERR.puts error_message
else
  parser = SpecAnalyzer::Parser.new

  root = parser.parse_file ARGV[0]

  puts JSON.dump root.to_hash
end
