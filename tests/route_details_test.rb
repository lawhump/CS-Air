require 'minitest/autorun'
require 'json'
require_relative '../app/graph'

class RouteDetailsTest < Minitest::Test

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

  # Basic test to see if I can make and access my object in
  # a predictable manner
  # All calculations I did by hand
  def test_basic
    smallerGraph = Graph.new('/Users/lawrencehumphrey/RubymineProjects/csair/app/data/cmi_chi_lax_sfo.json')

    route1 = ['LAX', 'SFO']
    route2 = ['LAX', 'SFO', 'CHI']

    r1     = route1.dup
    r2     = route2.dup
    r3     = route1.dup
    r4     = route2.dup
    r5     = route1.dup
    r6     = route2.dup

    time1  = smallerGraph.getTimeOfRoute(r1)
    time2  = smallerGraph.getTimeOfRoute(r2)

    dist1  = smallerGraph.getDistanceOfRoute(r3)
    dist2  = smallerGraph.getDistanceOfRoute(r4)

    price1 = smallerGraph.getPriceOfRoute(r5)
    price2 = smallerGraph.getPriceOfRoute(r6)

    assert_equal(543, dist1, 'Distance 1 is wrong')
    assert_equal(3537, dist2, 'Distance 2 is wrong')

    assert_equal(190.05, price1, 'Price 1 is wrong')
    assert_equal(1088.25, price2.round(2), 'Price 2 is wrong')

    assert_equal(1.26, time1.round(2), 'Time 1 is wrong')
    assert_equal(7.28, time2.round(2), 'Time 2 is wrong')
  end
end