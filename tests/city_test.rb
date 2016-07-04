require 'minitest/autorun'
require 'json'
require '../app/city'

class CityTest < Minitest::Test

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

    assert_match("SCL", city.code)
    assert_match("Santiago", city.name)
    assert_equal(city.population, 6000000)
    assert_equal(city.timezone, -4)
    assert_match("CL", city.location.country)
    assert_match("South America", city.location.continent)
    assert_equal(city.location.region, 1)
  end
end