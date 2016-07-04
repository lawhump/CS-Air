require 'minitest/autorun'
require 'json'
require '../app/graph'

# I don't really know how I'm expected to verify my answers.
# Reading through the JSON and comparing things by hand is not gonna happen.
class GraphStatsTest < Minitest::Test

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Basic test to see if I can make and access my object in a
  # predictable manner
  def test_graph
    graph = Graph.new("../app/map_data.json")

    # Graph stats
    gs = graph.gs

  end
end