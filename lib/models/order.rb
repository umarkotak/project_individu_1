require 'json'

module GoCLI
  class Point
    attr_accessor :x, :y
    def initialize(x, y)
      @x = x
      @y = y
    end
  end

  class Order
    attr_accessor :position, :destination, :status, :type, :distance, :price, :fleet_name, :timestamp, :price

    def initialize(opts = {})
      @position = opts[:position]
      @destination = opts[:destination]
      @type = opts[:type]
      @timestamp = opts[:timestamp]
      @price = opts[:price]
    end

    def validate_loc(location)
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/locations.json")
      data = JSON.parse(file)
      info = {}
      data.each do |e|
        info = e if e.has_value?(location)
      end
      info
    end

    def calculate_distance(p1, p2)
      long = Math.sqrt((p2.x - p1.x) ** 2 + (p2.y - p1.y) ** 2)
      long
    end

    def search_fleet(p1, type)
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json")
      data = JSON.parse(file)
      fleet_name = []
      data.each do |hsh|
        p3 = Point.new(hsh["coord"][0], hsh["coord"][1])
        distance = calculate_distance(p1, p3)
        fleet_name << hsh["driver"] if distance <= 1 && hsh["type"] == type
      end
      fleet_name
    end

    def driver_move(fleet_name, destination)
      file_driver = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json")
      data_driver = JSON.parse(file_driver)

      file_location = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/locations.json")
      data_location = JSON.parse(file_location)

      coord = []
      data_location.each { |hsh| coord << hsh["coord"] if hsh["name"] == destination }

      data_driver.each { |hsh| hsh["coord"] = coord[0] if hsh["driver"] == fleet_name }

      # puts data_location
      # puts data_driver

      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json", "w") do |f|
        f.write JSON.generate(data_driver)
      end
    end

    def save!
      order = {timestamp: @timestamp, position: @position, destination: @destination, price: @price}

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders2.json")
      data = JSON.parse(file)
      data << order

      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders2.json", "w") do |f|
        f.write JSON.generate(data)
      end
    end

    def show_history      
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders2.json")
      data = JSON.parse(file)

      data
    end

    def self.check_promo(code)
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/promo.json")
      data = JSON.parse(file)
      potongan = 0
      data.each do |hsh|
        potongan = hsh["potongan"].to_i  if hsh["kode_promo"] == code
      end

      potongan
    end
  end
end