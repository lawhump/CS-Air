require './graph'
require './graph_stats'
require './user_interface'

if __FILE__ == $0
    CS_Air = Graph.new('./data/map_data.json')
    # TODO uncomment after testing
    CS_Air.addData('./data/cmi_hub.json')
    print "Welcome to CSAir! I'm LawrenceBot and I'll be here to help.\n"

    UI.new(CS_Air)
end
