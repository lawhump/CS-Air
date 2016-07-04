class EndpointCity
    def initialize(*args)
        # City is the actual city object
        # Distance is how far it is from some metro
        @city     = args[0]
        @distance = args[1]
    end
    attr_reader :city, :distance
end
