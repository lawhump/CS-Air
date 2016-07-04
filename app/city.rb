require_relative './location'

class City
    def initialize(*args)
        if args.length > 1
            @code 	    = args[0]
            @name 	    = args[1]
            @timezone   = args[2]
            @population = args[3]
            @location   = Location.new(args[4], args[5], args[6], args[7])

        else
            metro = args.first
            @code 	    = metro['code']
            @name 	    = metro['name']
            @timezone   = metro['timezone']
            @population = metro['population']
            @location   = Location.new(metro['country'],
                                       metro['continent'],
                                       metro['coordinates'],
                                       metro['region'])
        end
    end

  attr_accessor :code, :name, :population
  attr_reader :timezone, :location
end
