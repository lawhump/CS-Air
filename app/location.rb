class Location
    def initialize(country, continent, lat_and_lon, region)
      @country 	   = country
      @continent 	 = continent
      @lat_and_lon = lat_and_lon
      @region 	   = region
    end

    attr_reader :country, :continent, :lat_and_lon, :region
end