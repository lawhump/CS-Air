require 'minitest/autorun'
require 'json'
require '../app/graph'

class GraphTest < Minitest::Test

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

    # Two variables that are probably important to validate proper behavior
    metros = graph.metros
    routes = graph.routes

    # by looking at map_data.json
    toronto = metros.last

    assert_match("YYZ", toronto.code)
    assert_match("Toronto", toronto.name)
    assert_match("CA", toronto.location.country)
    assert_match("North America", toronto.location.continent)
    assert_equal(3, toronto.location.region)
    assert_equal(5750000, toronto.population)
    # idc at latitude and longitude if you can't tell

    tor_routes = routes[toronto]

    # I know this because I did this
    # p tor_routes.index { |ep| ep.city.name.match("Chicago") }
    ep_chicago = tor_routes[0]
    assert_equal(684, ep_chicago.distance)
    chicago    = ep_chicago.city

    assert_match("Chicago", chicago.name)
  end
end