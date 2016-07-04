require './graph'
require './graph_stats'

class UI
    # Needs the graph in order to query it
    def initialize(network)
        @my_network = network
        mainMenu
    end

    # The main menu for the interface.
    # From here you can:
    #  * See details about a specific city
    #  * See statistics about the network as a whole
    #  * Exit the program all together
    # Includes the printing to console and handles first user input
    def mainMenu
        print "What would you like to know more about?\n"

        print " * Details about a specific city. (c)\n"
        print " * Details about our network - metros and routes. (n)\n"
        print " * Details about a specific route. (r)\n"
        print " * Visualize our network. (v)\n"
        print " * Save current state of the network. (s)\n"
        print " * Exit. (x)\n"

        query = gets.chomp.to_s

        if query.match(/[cC]/)
            inputCity
        elsif query.match(/[nN]/)
            networkDetails
        elsif query.match(/[rR]/)
            routeDetails
        elsif  query.match(/[vV]/)
            visualize
        elsif query.match(/[sS]/)
            save
        elsif query.match(/[xX]/)
            exit
        else
            error
        end
    end

    # The user wants to know more about a city.
    # Requires them to put in their code or name.
    def inputCity
        print "Which city do you have in mind? Input its name or code.\n"

        input = gets.chomp

        # Try querying by name
        cityIdx = @my_network.metros.find_index {|metro| metro.name.upcase == input.upcase }
        if  cityIdx != nil
            cityDetails(@my_network.metros[cityIdx])
        # Didn't work; try querying by code
        end
        cityIdx = @my_network.metros.find_index {|metro| metro.code.upcase == input.upcase }
        if cityIdx != nil
            cityDetails(@my_network.metros[cityIdx])
        # I don't know what you want from me man
        else
            print "That's an invalid metro.\n"
            print "The cities in the metro are:\n"
            print "#{@my_network.getCitiesByName}\n"
            inputCity
        end
    end

    # We found the city the user wants to know more about.
    # Ask what they want to know about said city.
    # Handles user input
    def cityDetails(city)
        print "You selected #{city.name}\n"
        print "Do you want to know this city's:\n"
        print " * Code. (c)\n"
        print " * Name. (n)\n"
        print " * Country. (cy)\n"
        print " * Continent. (ct)\n"
        print " * Timezone. (t)\n"
        print " * Latitude and longitude. (l)\n"
        print " * Population. (p)\n"
        print " * Region. (r)\n"
        print " * Flights from this metro. (f)\n"
        print " * Edit. (e)\n"
        print " * Remove. (rm)\n"
        print " * Back. (b)\n"
        print " * Exit. (x)\n"

        query = gets.chomp
        exiting = false

        # Get what the user wants to see, man
        if query.match(/^c$/i)
            print "#{city.name}'s code is #{city.code}\n"
        elsif query.match(/[nN]/)
            print "#{city.code} has name #{city.name}\n"
        elsif query.match(/cy/i)
            print "#{city.name} is in #{city.location.country}\n"
        elsif query.match(/ct/i)
            print "#{city.name} is in #{city.location.continent}\n"
        elsif query.match(/[t]/i)
            print "#{city.name} is in timezone #{city.location.timezone}\n"
        elsif query.match(/[l]/i)
            print "#{city.name} has latitude #{city.location.lat_and_lon}\n"
        elsif query.match(/[p]/i)
            print "#{city.name} has population #{city.population}\n"
        elsif query.match(/^r$/i)
            print "#{city.name} has region code #{city.location.region}\n"
        elsif query.match(/[f]/i)
            print "This metro has flights to: #{@my_network.getFlightsByNameFrom(city).join(', ')}\n"
        elsif query.match(/[e]/)
            edit(city)
        elsif query.match(/rm/)
            removeDialog(city)
        elsif query.match(/[bB]/)
            inputCity
        elsif query.match(/[xX]/)
            exiting = true
            exit
        else
            error
        end

        # Make one of the options default with caps
        unless exiting
            print "Do you want to know anything else about #{city.name}? (y/n)\n"

            # Do they want to know something else about this city?
            continue = gets.chomp
            if continue.match(/y/i)
                cityDetails(city)

            elsif continue.match(/n/i)
                mainMenu

            else
                error
            end
        end
    end

    # The user wants to modify the city data for whatever reason
    # Ask what they want to change
    def edit(city)
        puts "What did you wish to edit about #{city.name}?"
        puts " * Name. (n)"
        puts " * Code. (c)"
        puts " * Population. (p)"
        puts " * Back (b)"

        cityField = gets.chomp

        if cityField.match(/[nN]/)
            editCityName(city)
        elsif cityField.match(/[cC]/)
            editCityCode(city)
        elsif cityField.match(/[pP]/)
            editCityPopulation(city)
        elsif cityField.match(/[bB]/)
            cityDetails(city)
        else
            error
        end
    end

    # Change the name of said city to the parameter name
    def editCityName(city)
        puts "What's #{city.name}'s new name?"
        newName = gets.chomp
        @my_network.editCityName(city, newName)
    end

    # Change the code of said city to the parameter code
    def editCityCode(city)
        puts "What's #{city.name}'s new code?"
        newCode = gets.chomp
        @my_network.editCityCode(city, newCode)
    end

    # Change the population of said city to the parameter population
    def editCityPopulation(city)
        puts "What's #{city.name}'s new population?"
        newPopulation = gets.chomp
        @my_network.editCityPopulation(city, newPopulation)
    end

    # Asks the user if they really want to delete said city.
    # Deletes if they really want to. Main menu if not.
    def removeDialog(city)
        print "Are you sure you want to remove #{city.name}? (y/n)\n"

        confirmation = gets.chomp

        if confirmation.match(/[nN]/)
            mainMenu
        elsif confirmation.match(/[yY]/)
            @my_network.removeCity(city)
            inputCity
        else
            error
        end
    end

    # The user wants to see network statistics
    # Handles user input
    def networkDetails
        print "What would you like to know about our network?\n"
        print " * Longest flight. (lf)\n"
        print " * Shortest flight. (sf)\n"
        print " * Average flight distance. (af)\n"
        print " * Largest city. (lc)\n"
        print " * Smallest city. (sc)\n"
        print " * Average city size. (ac)\n"
        print " * Continents served. (cs)\n"
        print " * Hub cities. (hc)\n"
        print " * Exit. (x)\n"

        # Handle user's query
        query = gets.chomp
        exiting = false

        if query.match(/lf/i)
            print "The longest flight is #{@my_network.gs.longest_flight} units\n"

        elsif query.match(/sf/i)
            print "The shortest flight is #{@my_network.gs.shortest_flight} units\n"

        elsif query.match(/af/i)
            print "The average flight length is #{@my_network.gs.average_flight} units\n"

        elsif query.match(/lc/i)
            print "The largest city is #{@my_network.gs.largest_city.name} with population #{@my_network.gs.largest_city.population}\n"

        elsif query.match(/sc/i)
            print "The smallest city is #{@my_network.gs.smallest_city.name} with population #{@my_network.gs.smallest_city.population}\n"

        elsif query.match(/ac/i)
            print "The average city size is #{@my_network.gs.average_city}\n"

        elsif query.match(/cs/i)
            print "We serve: #{@my_network.gs.continents_served.join(', ')}\n"

        elsif query.match(/hc/i)
            print "The cities with the most number of outgoing flights: #{@my_network.gs.printHubCities.join(', ')}.\n"

        elsif query.match(/x/i)
            exiting = true
            exit

        else
            error

        end

        unless exiting
            print "Did you want to see more statistics? (y/n)\n"

            # Continue looking at network stats
            continue = gets.chomp
            if continue.match(/y/i)
                networkDetails

            elsif continue.match(/n/i)
                mainMenu

            else
                error
            end
        end
    end

    # User wants to learn more about a specific route
    def routeDetails
        puts "Which route do you want to learn about? Enter the codes separated by spaces."
        puts "#{@my_network.getCitiesByName}"

        routes = gets.chomp
        routesArr = routes.split

        @my_network.routeDetails(routesArr)
        mainMenu
    end

    # Instead of hijacking the user's machine, allow them to click (or not click) the link
    def visualize
        print "Follow this link to see our network:\n"
        print @my_network.url

        mainMenu
    end

    # Save the current state of the network to JSON
    def save
        @my_network.toJSON
        puts 'Saved to app/data/saved.json!'
        mainMenu
    end
    # The nicest message I could think of demanding the user not be an idiot/so careless
    # Make him/her try again
    def error
        print "Didn't quite catch that, can you try again?\n"
        mainMenu
    end

    # Good riddance
    def exit
        abort("Peace dude!\n")
    end
end
