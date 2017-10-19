require_relative './models/user'
require_relative './models/order'
require_relative './view'
require 'date'
require 'time'

module GoCLI
  # Controller is a class that call corresponding models and methods for every action
  class Controller
    # This is an example how to create a registration method for your controller
    def registration(opts = {})
      halt = false
      until halt == true
        # First, we clear everything from the screen
        clear_screen(opts)

        # Second, we call our View and its class method called "registration"
        # Take a look at View class to see what this actually does
        form = View.registration(opts)

        # This is the main logic of this method:
        # - passing input form to an instance of User class (named "user")
        # - invoke ".save!" method to user object
        # TODO: enable saving name and email
        user = User.new(
          name:     form[:name],
          email:    form[:email],
          phone:    form[:phone],
          password: form[:password],
          saldo:    0
        )

        if user.validate == true
          halt = true
          user.save!

          # Assigning form[:user] with user object
          form[:user] = user
          form[:flash_msg] = 'Your account successfully created'
        else
          form[:flash_msg] = 'Something wrong when creating new account'
        end
      end # End of while
      # Returning the form
      form
    end

    # login method start
    def login(opts = {})
      halt = false
      until halt == true
        clear_screen(opts)
        form = View.login(opts)

        # Check if user inputs the correct credentials in the login form
        if credential_match?(form[:user], form[:login], form[:password])
          halt = true
        else
          form[:flash_msg] = 'Wrong login or password combination'
        end
      end

      form
    end

    # main menu method start
    def main_menu(opts = {})
      clear_screen(opts)
      form = View.main_menu(opts)

      case form[:steps].last[:option].to_i
      when 1
        # Step 4.1
        view_profile(form)
      when 2
        # Step 4.2
        order_goride(form)
      when 3
        # Step 4.3
        view_order_history(form)
      when 4
        exit(true)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        main_menu(form)
      end
    end

    def view_profile(opts = {})
      clear_screen(opts)
      form = View.view_profile(opts)

      case form[:steps].last[:option].to_i
      when 1
        # Step 4.1.1
        edit_profile(form)
      when 2
        topup_gopay(form)
      when 3
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        view_profile(form)
      end
    end

    def topup_gopay(opts = {})
      clear_screen(opts)
      form = View.topup_gopay(opts)

      case form[:steps].last[:option].to_i
      when 1
        saldo = form[:saldo].to_i
        if saldo.is_a?(Numeric) && saldo > 0

          User.topup_gopay(saldo)
          form[:user] = User.load
          view_profile(form)

        else
          topup_gopay(form)
        end
      when 2
        topup_gopay(form)
      when 3
        view_profile(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        topup_gopay(form)
      end
    end

    # TODO: Complete edit_profile method
    # This will be invoked when user choose Edit Profile menu in view_profile screen
    def edit_profile(opts = {})
      clear_screen(opts)
      form = View.edit_profile(opts)

      case form[:steps].last[:option].to_i
      when 1
        user = User.new(
          name:     form[:name],
          email:    form[:email],
          phone:    form[:phone],
          password: form[:password],
          saldo:    form[:user].saldo
        )
        user.save!
        form[:user] = user
        form[:flash_msg] = 'Your data successfully edited'
        view_profile(form)
      when 2
        view_profile(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        edit_profile(form)
      end
    end

    # TODO: Complete order_goride method
    def order_goride(opts = {})
      clear_screen(opts)

      opts[:available_loc] = available_loc
      opts[:driver_position_status] = driver_position_status

      form = View.order_goride(opts)

      location = Order.new(
        position: form[:position],
        destination: form[:destination],
        type: form[:type]
      )

      pos = location.validate_loc(location.position)
      dest = location.validate_loc(location.destination)

      # p loc.position
      # p form[:position]
      form[:location] = location
      if !pos.empty? && !dest.empty?

        p1 = Point.new(pos['coord'][0], pos['coord'][1])
        p2 = Point.new(dest['coord'][0], dest['coord'][1])

        location.distance = location.calculate_distance(p1, p2)

        promo_code = form[:promo_code]

        potongan = Order.check_promo(promo_code)
        form[:potongan] = potongan

        if location.type.to_i == 1
          location.price = (location.distance * 1500) - potongan.to_f
          location.type = 'gojek'
        elsif location.type.to_i == 2
          location.price = (location.distance * 2500) - potongan.to_f
          location.type = 'gocar'
        else
          location.price = (location.distance * 1500) - potongan.to_f
        end

        location.fleet_name = location.search_fleet(p1, location.type)[0]

        # p location.fleet_name

        if location.fleet_name != nil
          location.status = true
        else
          location.status = false
        end

        # p location.status

        order_goride_confirm(form)
      else
        form[:flash_msg] = 'Your service for that route is unavailable'
        order_goride(form)
      end
    end

    # TODO: Complete order_goride_confirm method
    # This will be invoked after user finishes inputting data in order_goride method
    def order_goride_confirm(opts = {})
      clear_screen(opts)

      status = opts[:location].status

      # Validation view if driver available
      if status == true
        form = View.order_goride_confirm(opts)
      else
        form = View.order_goride_confirm_fail(opts)

        case form[:steps].last[:option].to_i
        when 1
          order_goride(form)
        when 2
          main_menu(form)
        else
          form[:flash_msg] = 'Wrong option entered, please retry.'
          order_goride_confirm(form)
        end
      end

      # Confirmation option action
      case form[:steps].last[:option].to_i
      when 1

        if form[:paymethods].to_i == 1

        elsif form[:paymethods].to_i == 2
          saldo = form[:user].saldo
          price = form[:location].price

          # gopay validation
          # gopay substraction
          if saldo > price
            User.subtract_gopay(price)
            form[:user] = User.load
          else
            form[:flash_msg] = 'Insufficient Gopay credit'
            order_goride_confirm(form)
          end
        else
          form[:flash_msg] = 'Wrong payment methods'
          order_goride_confirm(form)
        end

        # p form[:timestamp] = Date.today
        # p form[:location].position

        order = Order.new(
          timestamp:    Time.now,
          position:     form[:location].position,
          destination:  form[:location].destination,
          price:        form[:location].price
        )

        order.save! # to save the order

        fleet_name = form[:location].fleet_name
        destination = form[:location].destination

        driver = Order.new(
          fleet_name:   fleet_name,
          destination:  destination
        )

        driver.driver_move(fleet_name, destination) # move the driver

        form[:flash_msg] = 'Your order has been confirmed'
        main_menu(form)
      when 2
        order_goride(form)
      when 3
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        order_goride_confirm(form)
      end
    end

    def view_order_history(opts = {})
      clear_screen(opts)

      order = Order.new

      opts[:history] = order.show_history

      form = View.view_order_history(opts)

      case form[:steps].last[:option].to_i
      when 1
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        view_order_history(form)
      end
    end

  protected

    # You don't need to modify this
    def clear_screen(opts = {})
      Gem.win_platform? ? (system 'cls') : (system 'clear')
      if opts[:flash_msg]
        puts opts[:flash_msg]
        puts ''
        opts[:flash_msg] = nil
      end
    end

    # TODO: credential matching with email or phone
    def credential_match?(user, login, password)
      return false unless user.phone == login || user.email == login
      return false unless user.password == password
      true
    end

    def available_loc
      str = []
      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../data/locations.json")
      JSON.parse(file).each do |hsh|
        hsh.each { |key, val| str << val if key == 'name' }
      end
      # data = JSON.parse(file).each do |hsh|
      #   hsh.each { |key, val| str << val if key == 'name' }
      # end
      str
    end

    def driver_position_status
      str = ''

      str
    end
  end
end
