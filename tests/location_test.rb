require 'minitest/autorun'
require 'json'
require '../app/city'

class LocationTest < Minitest::Test

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
  def test_basic
    city_obj = {
        code: "SCL",
        name: "Santiago",
        country: "CL",
        continent: "South America",
        timezone: -4 ,
        coordinates: {S: 33, W: 71} ,
        population: 6000000 ,
        region: 1
    }

    city = City.new(JSON.parse(city_obj.to_json))
    location = city.location

    assert_match("CL", location.country)
    assert_match("South America", location.continent)
    assert_equal(1, location.region)
  end
end