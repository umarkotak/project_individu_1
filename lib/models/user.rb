require 'json'

module GoCLI
  class User
    attr_accessor :name, :email, :phone, :password, :saldo

    # TODO: 
    # 1. Add two instance variables: name and email 
    # 2. Write all necessary changes, including in other files
    def initialize(opts = {})

      @name = opts[:name] || ''
      @email = opts[:email] || ''
      @phone = opts[:phone] || ''
      @password = opts[:password] || ''
      @saldo = opts[:saldo] || ''

    end

    def self.load
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")
      # this will return nil when file not exist

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")
      data = JSON.parse(file)

      self.new(
        name:     data['name'],
        email:    data['email'],
        phone:    data['phone'],
        password: data['password'],
        saldo:    data['saldo']
      )
    end

    # TODO: Add your validation method here
    def validate
      false
      true if @name == "umar"
    end

    def save!
      # TODO: Add validation before writing user data to file
      # kalau masukan user kosong

      user = {name: @name, email: @email, phone: @phone, password: @password, saldo: @saldo}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json", "w") do |f|
        f.write JSON.generate(user)
      end
    end

    def self.topup_gopay(ammount)
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")
      data = JSON.parse(file)

      data["saldo"] += ammount
      
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json", "w") do |f|
        f.write JSON.generate(data)
      end
    end

    def self.subtract_gopay(ammount)
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")
      data = JSON.parse(file)

      data["saldo"] -= ammount
      
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json", "w") do |f|
        f.write JSON.generate(data)
      end
    end
  end
end
