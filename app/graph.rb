require 'json'
require_relative './city'
require_relative './endpoint_city'
require_relative './graph_stats'

# Represents the network of cities
class Graph
	# Create the graphical representation of the .json file
	# Params:
	# +path+:: Path to the .json file you wish to read from
	def initialize(path)
    # List of the cities in our network
    @metros = Array.new
    # Map of connecting flights from some arbitrary city
    @routes = Hash.new
    # Lookup city by code
    @@code_to_city = Hash.new

    createGraphFromJSON(path)

    # All of the interesting stats about the netwerk
    @gs = GraphStats.new(@metros, @routes)

    # URL for that site w/e
    @url = "http://www.gcmap.com/mapui?P=#{buildVisualization}"

    # getShortestPath('CHI', 'PEK')
  end

	# Reads from the JSON file located at path
	# Params:
	# +path+:: Path to the desired .json file
	def createGraphFromJSON(path)
    file 	    = File.read(path)
    data_hash = JSON.parse(file)

    # Put metro and route data in arrays to be processed
    metrosJSON = data_hash['metros']
    routesJSON = data_hash['routes']

    # Process metro data
    processMetroData(metrosJSON)

    # Process route data
    processRouteData(routesJSON)
  end

  def addData(path='./data/cmi_hub.json')
    file 	    = File.read(path)
    data_hash = JSON.parse(file)

    # Put metro and route data in arrays to be processed
    metrosJSON = data_hash['metros']
    routesJSON = data_hash['routes']

    processMetroData(metrosJSON)
    processRouteData(routesJSON)

    # regenerate the data anytime you add new stuff
    @gs.generateStats(@metros, @routes)
  end

  # Turns the metro JSON into an array of cities
  # Params:
  # +metrosJSON+:: The JSON array of metros
  def processMetroData(metrosJSON)
    metrosJSON.each { |metro|
      city = City.new(metro)
      @metros.push(city)
      @@code_to_city[metro['code']] = city
      @routes[city] = []
    }
  end

  # Turns the metro JSON into an array of cities
  # Params:
  # +routesJSON+:: The JSON array of metros
  def processRouteData(routesJSON)
    routesJSON.each { |route|
      ports      = route['ports']
      start_code = ports[0]
      end_code   = ports[1]

      start_city = @@code_to_city[start_code]
      end_city   = @@code_to_city[end_code]

      # Because of symmetry
      @routes[start_city].push(EndpointCity.new(end_city, route['distance']))
      @routes[end_city].push(EndpointCity.new(start_city, route['distance']))
    }
  end

  # Gets all metros BY NAME connected to city
  # Wanted to take some of the computation off of the interface
  # Params:
  # +city+:: Object. The city we are exploring from.
  def getFlightsByNameFrom(city)
      eps      = @routes[city]
      ep_names = []
      eps.map { |ep| ep_names.push(ep.city.name) }
      return ep_names
  end

  # Name is kind of misleading and anticlimactic
  # Builds the URL needed such that you can see your vis
  def buildVisualization
    pairs = []
    # sp - start point; eps - endpoints
    @routes.each { |sp, eps|
      eps.each { |ep|
        pairs.push("#{sp.code}-#{ep.city.code}")
      }
    }
    return pairs.join(',+') + "\n"
  end

  # Gets all metros BY NAME connected to city
  # Wanted to take some of the computation off of the interface
  def getCitiesByName
    names = []
    @metros.map { |metro| names.push(" ~  #{metro.name} - #{metro.code}") }
    return names.join("\n")
  end

  # Add this city to our network of metros
  def addCity(city)
    @metros.push(city)
  end

  # Add this route between these two cities/metros
  def addRoute(city1, city2, distance)
    @routes[city1].push(EndpointCity.new(city2, distance))
    @routes[city2].push(EndpointCity.new(city1, distance))
  end

  def removeCity(city)
    # Remove from metros
    @metros.delete_at(@metros.find_index(city))

    @routes[city].each { |deletedEPs|
      # For each endpoint city, remove current city from its list
      @routes[deletedEPs.city].keep_if { |ep| ep.city.name != city.name }
    }

    # Remove the hash
    @routes.delete(city)
    puts "Deleted."
  end

  def editCityName(city, name)
    # If the name exists already
    if (@metros.index { |metro| metro.name == name }) != nil
      # Because this is command-line driven, I can just print to console
      puts "#{name} is already taken."
    else
      puts "Changed city name from #{city.name} to #{name}."
      city.name = name
    end
  end

  def editCityCode(city, code)
    code = code.upcase
    # If the code exists already
    if (@metros.index { |metro| metro.code == code }) != nil
      # Because this is command-line driven, I can just print to console
      puts "#{code} is already taken."
    else
      puts "Changed city code from #{city.code} to #{code}."
      city.code = code
    end
  end

  def editCityPopulation(city, population)
    puts "Changed city population from #{city.population} to #{population}."
    city.population = population
  end

  # The things users want to know about when they're flying
  # i.e. Time and cost - and distance, but that's just bc this assignment is making me
  # Params:
  # +stops+:: List of stops' codes that flight will make
  def routeDetails(stops)
    stops.map { |stop| stop.upcase! }

    s1 = stops.dup
    s2 = stops.dup
    s3 = stops.dup
    # Inefficient. Could totally consolidate this into a single step, but
    # then this function could get big and messy.
    totalDistance = getDistanceOfRoute(s1)

    unless totalDistance == -1
      totalTime     = getTimeOfRoute(s2)
      totalPrice    = getPriceOfRoute(s3)

      # I don't really like the idea of printing inside of here, as I can see it getting
      # confusing for later debugging/finding out what's printing from where. Alas.
      puts " Total distance: #{totalDistance}km"
      puts " Price: $#{totalPrice}"
      puts " Total travel time: #{totalTime}hrs"
    end
  end

  # Get how long the flight will take including layovers from city1 -> city2 -> ... cityN
  # Params:
  # +stops+:: List of stops' codes that flight will make
  def getTimeOfRoute(stops)
    # all computation should be in seconds
    time = 0
    timeAccelerating = (200.0/375.0)*3600  # Time of the period of acceleration/deceleration

    velocityKPS = 750.0 / 3600.0    # Velocity in kilometers per second

    accelerationKPH = 225.0/64.0    # Acceleration in kilometers per hour
    accelerationKPS = accelerationKPH / 3600.0 # Acceleration in kilometers per seconds squared

    connectingFlight = false

    until stops.length == 1
      leg = stops[0..1]
      distance = getDistanceOfRoute(leg)

      # Airtime logic
      if distance > 400
        time += 2*timeAccelerating
        time += (distance-400)/velocityKPS
      else
        time += 2*Math.sqrt(distance/accelerationKPS)
      end

      if connectingFlight
        time += layoverTime(stops[0])
      end
      connectingFlight = true
      stops.shift
    end

    return (time / 3600).round(2)
  end

  # How long will the layover in this city take
  # Params:
  # +stop+:: Current place where we're stopped
  def layoverTime(stop)
    return 7200 - 600*@routes[@@code_to_city[stop]].length
  end

  # Calculates the total price of this trip
  # Params:
  # +stops+:: The stops of this current flight
  def getPriceOfRoute(stops)
    price       = 0
    priceFactor = 0.35

    # Use the distance function with just one leg of the trip
    until stops.empty?
      leg = stops[0..1]
      distance = getDistanceOfRoute(leg)
      price += priceFactor * distance
      priceFactor -= 0.05
      stops.shift
    end

    return price.round(2)
  end

  # Pretty self-explanatory really.
  # Params:
  # +stops+:: The stops of this current flight
  def getDistanceOfRoute(stops)
    distance = 0

    $index1 = 0
    $index2 = 1

    while $index2 < stops.length
      sp = stops[$index1]
      ep = stops[$index2]

      spDestinations = @routes[@@code_to_city[sp]]

      target = spDestinations.find { |endpoint| endpoint.city.code == ep }

      if target == nil
        # invalid route
        puts 'This is an invalid route.'
        return -1
      end

      distance += target.distance

      $index1+=1
      $index2+=1
    end

    return distance
  end

  # Obvious
  # Params:
  # Type: City
  # +startpt+:: Where you'll be traveling from
  # +endpt+:: Where you'll be traveling to
  def getShortestPath(startpt, endpt)
    # create vertex set Q
    # initialize weights
    unseen = []
    seen   = []
    @metros.map{ |metro|
      v = DNode.new(metro.code)
      if startpt == metro.code
        v.weight = 0
      end
      unseen.push(v)
    }

    until unseen.empty?
      curr = unseen.min_by(&:weight)
      seen.push(curr)
      unseen.delete(curr)

      @routes[@@code_to_city[curr.code]].each{ |neighbor|
        unless seen.flatten.include?(neighbor.city.code)
          neighbor_node       = unseen.index { |node| node.code == neighbor.city.code }
          cumulative_distance = curr.weight + neighbor.distance

          if cumulative_distance < unseen[neighbor_node].weight
            unseen[neighbor_node].weight = cumulative_distance
            unseen[neighbor_node].prev   = curr
          end
        end
      }
    end

  end

  class DNode
    def initialize(code)
      @code   = code
      @weight = Float::INFINITY
      @prev   = nil
    end
    attr_accessor :weight, :prev
    attr_reader :code
  end

  # Convert this graph into JSON format and save it
  # TODO Make it such that you can choose the name of saved file
  # Although, I don't want a billion files all over the place so idk
  def toJSON
    jsonObj = {}

    # metros to json
    metros = []
    @metros.each { |metro|
      hash = {}
      hash['code']        = metro.code
      hash['name']        = metro.name
      hash['country']     = metro.location.country
      hash['continent']   = metro.location.continent
      hash['timezone']    = metro.timezone
      hash['coordinates'] = metro.location.lat_and_lon
      hash['population']  = metro.population
      hash['region']      = metro.location.region
      metros.push(hash)
    }

    # routes to json
    routes = []
    @routes.each{ |sp, eps|
      hash = {}
      eps.each { |ep|
        ports = []
        ports.push(sp.code)
        ports.push(ep.city.code)

        distance = ep.distance

        hash['ports']    = ports
        hash['distance'] = distance
      }
      routes.push(hash)
    }

    # put it all together
    jsonObj['data source'] = [
        'http://www.gcmap.com/',
        'http://www.theodora.com/country_digraphs.html',
        'http://www.citypopulation.de/world/Agglomerations.html',
        'http://www.mongabay.com/cities_urban_01.htm',
        'http://en.wikipedia.org/wiki/Urban_agglomeration',
        'http://www.worldtimezone.com/standard.html'
    ]
    jsonObj['metros']      = metros
    jsonObj['routes']      = routes

    # write prettified result to file
    File.open('./data/saved.json','w') do |f|
      f.write(JSON.pretty_generate(jsonObj))
    end
  end

  attr_reader :metros, :routes, :code_to_city, :gs, :url
end
