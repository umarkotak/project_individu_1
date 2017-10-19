require 'date'
module GoCLI
  # View is a class that show menus and forms to the screen
  class View
    # This is a class method called ".registration"
    # It receives one argument, opts with default value of empty hash
    # TODO: prompt user to input name and email
    def self.registration(opts = {})
      form = opts

      puts 'Registration'
      puts ''

      print 'Your name     : '
      form[:name] = gets.chomp

      print 'Your email    : '
      form[:email] = gets.chomp

      print 'Your phone    : '
      form[:phone] = gets.chomp

      print 'Your password : '
      form[:password] = gets.chomp

      form[:steps] << {id: __method__}

      form
    end

    def self.login(opts = {})
      form = opts

      puts 'Login'
      puts ''

      print 'Enter your login    : '
      form[:login] = gets.chomp

      print 'Enter your password : '
      form[:password] = gets.chomp

      form[:steps] << {id: __method__}

      form
    end

    def self.main_menu(opts = {})
      form = opts

      puts 'Welcome to Go-CLI!'
      puts ''

      puts 'Main Menu'
      puts '1. View Profile'
      puts '2. Order Go-Ride'
      puts '3. View Order History'
      puts '4. Exit'

      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end

    # TODO: Complete view_profile method
    def self.view_profile(opts = {})
      form = opts

      puts 'View Profile'
      puts ''

      # Show user data here
      puts 'User Data : '
      puts "Name     : #{form[:user].name}"
      puts "Email    : #{form[:user].email}"
      puts "Phone    : #{form[:user].phone}"
      puts "password : #{form[:user].password}"
      puts "saldo    : #{form[:user].saldo}"
      puts ''

      puts '1. Edit Profile'
      puts '2. Topup Gopay'
      puts '3. Back'

      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end

    def self.topup_gopay(opts = {})
      form = opts

      puts 'Topup Gopay'
      puts ''

      print 'Masukkan saldo : '
      form[:saldo] = gets.chomp

      puts ''
      puts '1. Confirm'
      puts '2. Cancel'
      puts '3. Back'

      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end

    # TODO: Complete edit_profile method
    # This is invoked if user chooses Edit Profile menu when viewing profile
    def self.edit_profile(opts = {})
      form = opts

      puts 'Edit profile'
      puts ''

      # puts form
      # puts form[@name]
      # puts form[:user].name

      # editing user data here
      puts "Previous name : #{form[:user].name}"
      print 'New name: '
      form[:name] = gets.chomp

      puts "Previous email : #{form[:user].email}"
      print 'New email: '
      form[:email] = gets.chomp

      puts "Previous phone : #{form[:user].phone}"
      print 'New phone: '
      form[:phone] = gets.chomp

      puts "Previous password : #{form[:user].password}"
      print 'New password: '
      form[:password] = gets.chomp
      puts ''

      puts '1. Submit'
      puts '2. Cancel'
      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end

    # TODO: Complete order_goride method
    def self.order_goride(opts = {})
      form = opts

      puts 'Order goride'
      puts ''

      puts 'Current area of services :'
      puts "#{form[:available_loc]}"
      puts ''

      puts 'Driver position status :'
      puts "#{form[:driver_position_status]}"
      puts ''

      print 'Your position : '
      form[:position] = gets.chomp

      print 'Your destination : '
      form[:destination] = gets.chomp

      puts "1. Go Ojek"
      puts "2. Go Car"
      print 'Service type : '
      form[:type] = gets.chomp

      form
    end

    # TODO: Complete order_goride_confirm method
    # This is invoked after user finishes inputting data in order_goride method
    def self.order_goride_confirm(opts = {})
      form = opts

      puts 'Confirmation order'
      puts ''

      puts 'Order detail : '
      puts '--------------------------'
      puts "Date        : #{Date.today}"
      puts ''

      puts "Position    : #{form[:location].position}"
      puts "Destination : #{form[:location].destination}"
      puts "Distance    : #{form[:location].distance}"
      puts "Price       : #{form[:location].price}"
      puts "Type        : #{form[:location].type}"
      puts '--------------------------'
      puts "Driver      : #{form[:location].fleet_name}"
      puts ''

      puts '1. Cash'
      puts '2. Go Pay'
      print 'Choose payment methods : '
      form[:paymethods] = gets.chomp

      puts ''
      puts '1. Confirm order'
      puts '2. Retry order'
      puts '3. Back to main menu'
      print 'Enter your option      : '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end

    def self.order_goride_confirm_fail(opts = {})
      form = opts

      puts 'Your order is unavailable'
      puts 'No drivers nearby'
      puts ''

      puts 'Order detail : '
      puts '--------------------------'
      puts "Date        : #{Date.today}"
      puts ''

      puts "Position    : #{form[:location].position}"
      puts "Destination : #{form[:location].destination}"
      puts "Distance    : #{form[:location].distance}"
      puts "Price       : #{form[:location].price}"
      puts "Type        : #{form[:location].type}"
      puts '--------------------------'
      puts "Driver      : #{form[:location].fleet_name}"
      puts ''

      puts '1. Retry order'
      puts '2. Back to main menu'
      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end

    # TODO: Complete view_order_history method
    def self.view_order_history(opts = {})
      form = opts

      puts 'Order history'
      puts ''

      no = 1
      form[:history].each do |hsh|
        arr = []
        hsh.each_value { |val| arr << val }
        puts "nomor : #{no}"
        puts "timestamp : #{arr[0]}"
        puts '--------------------------'
        puts "origin      : #{arr[1]}"
        puts "destination : #{arr[2]}"
        puts "price       : #{arr[3]}"
        puts '--------------------------'
        puts ''
        no += 1
      end 
      
      puts ''
      puts '1. Back to main menu'
      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp}

      form
    end
  end
end
