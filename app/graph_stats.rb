require_relative './city'
require_relative './graph'

class GraphStats
    # Creates statistics based on the network of flights
    def initialize(metros, routes)
        # longest_flight is {start: end | distance(start, end) is the greatest}
        @longest_flight    = 0
        # shortest_flight is {start: end | distance(start, end) is the smallest}
        @shortest_flight   = 0
        # average_flight is length of an average flight
        @average_flight    = 0
        # largest_city is the city with the largest population
        @largest_city      = nil
        # smallest_city is the city with the smallest population
        @smallest_city     = nil
        # average_city is the average population of all of the served cities
        @average_city      = 0
        # continents_served is the list of continents that has a metro within
        @continents_served = []
        # hub_cities is a list of metros with the most flights
        @hub_cities        = []

        generateStats(metros, routes)
    end

    # Does the heavy lifting
    def generateStats(metros, routes)
        getLongestFlight(routes)
        getShortestFlight(routes)
        getAverageFlight(routes)

        getLargestCity(metros)
        getSmallestCity(metros)
        getAverageCity(metros)

        getContinentsServed(metros)
        getHubCities(routes)
    end

    def getLongestFlight(routes)
        endpoints = routes.values.flatten
        longest_flight = endpoints.max_by(&:distance)
        @longest_flight = longest_flight.distance
        return @longest_flight
    end

    def getShortestFlight(routes)
        endpoints = routes.values.flatten
        shortest_flight = endpoints.min_by(&:distance)
        @shortest_flight = shortest_flight.distance
        return @shortest_flight
    end

    def getAverageFlight(routes)
        endpoints = routes.values.flatten
        totalLength = endpoints.inject(0){|sum,ep| sum += ep.distance}
        # adjust for overcounting
        totalLength /= 2
        @average_flight = totalLength / (endpoints.length/2)
        return @average_flight
    end

    def getLargestCity(metros)
        @largest_city = metros.max_by(&:population)
        return @largest_city
    end

    def getSmallestCity(metros)
        @smallest_city = metros.min_by(&:population)
        return @smallest_city
    end

    def getAverageCity(metros)
        total_population = metros.inject(0){|sum, city| sum += city.population}
        @average_city = total_population / metros.length
        return @average_city
    end

    def getContinentsServed(metros)
        # If you add data, it'll add everything twice
        # Need to empty the array and do it again
        @continents_served = []
        # may have been able to do this using [hash].values
        continents_served_cities = metros.uniq { |metro| metro.location.continent }
        continents_served_cities.each { |city|
            @continents_served.push(city.location.continent)
        }
        return @continents_served
    end

    def getHubCities(routes)
        cities = []
        most = 6
        routes.each { |route|
            if route[1].length == most
                most = route[1].length
                # p route[0]
                cities.push(route[0])
            end
        }

        @hub_cities = cities
    end

    def printHubCities
        hub_cities = []
        @hub_cities.map { |city| hub_cities.push(city.name) }
        return hub_cities
    end

    attr_reader :longest_flight, :shortest_flight, :average_flight, :largest_city,
        :smallest_city, :average_city, :continents_served, :hub_cities
end
