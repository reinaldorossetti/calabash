module Calabash
  class Device
    include Utility

    @@default = nil

    def self.default
      @@default
    end

    def self.default=(value)
      @@default = value
    end

    attr_reader :identifier, :server, :http_client, :logger

    # Create a new device.
    # @param [String] identifier A token that uniquely identifies the device.
    #   On iOS, this is the device UDID, or a simulator name or UDID returned by
    #   `$ xcrun instruments -s devices`.
    #   On Android, this is the serial of the device, emulator or simulator
    #   returned by `$ adb devices`.
    # @param [Server] server A server object.
    #
    # @return [Device] A device.
    def initialize(identifier, server, options={})
      @identifier = identifier
      @server = server
      @logger = options[:logger] || Logger.new
      @http_client = HTTP::RetriableClient.new(server, options.fetch(:http_options, {}))
    end

    # Start the application and the test server
    #
    # @param [Application] application being tested.
    #   This has to be and instance of Android::Application
    #   when testing on an Android device.
    # @param [Hash] options
    def start_app(application, options={})
      if Managed.managed?
        Managed.start_app(application, options, self)
      else
        _start_app(application, options)
      end
    end

    # Shutdown the application and the test server
    def stop_app
      if Managed.managed?
        Managed.stop_app(self)
      else
        _stop_app
      end
    end

    # Do not modify
    # @see Screenshot#screenshot
    def screenshot(name=nil)
      if Managed.managed?
        Managed.screenshot(name, self)
      else
        path = Screenshot.obtain_screenshot_path!(name)
        _screenshot(path)
      end
    end

    # Do not modify
    def install_app(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.install_app(application, self)
      else
        _install_app(application)
      end
    end

    # Do not modify
    def ensure_app_installed(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.ensure_app_installed(application, self)
      else
        _ensure_app_installed(application)
      end
    end

    # Do not modify
    def uninstall_app(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.uninstall_app(application.identifier, self)
      else
        _uninstall_app(application.identifier)
      end
    end

    # Do not modify
    def clear_app_data(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.clear_app_data(application.identifier, self)
      else
        _clear_app_data(application.identifier)
      end
    end

    # Do not modify
    def port_forward(host_port)
      if Managed.managed?
        Managed.port_forward(host_port, self)
      else
        _port_forward(host_port)
      end
    end

    class EnsureTestServerReadyTimeoutError < RuntimeError; end

    # Ensures the test server is ready
    #
    # @raises [RuntimeError] Raises error when the server does not respond
    def ensure_test_server_ready(options={})
      begin
        Timeout.timeout(options.fetch(:timeout, 30), EnsureTestServerReadyTimeoutError) do
          loop do
            break if test_server_responding?
          end
        end
      rescue EnsureTestServerReadyTimeoutError => _
        raise 'Calabash server did not respond'
      end
    end

    def test_server_responding?
      abstract_method!
    end

    # Performs a `tap` on the (first) view that matches `query`.
    # @see Calabash::Gestures#tap
    def tap(query, options={})
      Query.ensure_valid_query(query)

      _tap(query, {duration: 0.5}.merge(options))
    end

    # Performs a `double_tap` on the (first) view that matches `query`.
    # @see Calabash::Gestures#double_tap
    def double_tap(query, options={})
      Query.ensure_valid_query(query)

      _double_tap(query, options)
    end

    # Performs a `long_press` on the (first) view that matches `query`.
    # @see Calabash::Gestures#long_press
    def long_press(query, options={})
      Query.ensure_valid_query(query)

      _long_press(query, options)
    end

    # Performs a `pan` on the (first) view that matches `query`.
    # @see Calabash::Gestures#pan
    def pan(query, from, to, options={})
      Query.ensure_valid_query(query)

      _pan(query, from, to, {duration: 0.5}.merge(options))
    end

    # Performs a `pan` between two elements.
    # @see Calabash::Gestures#pan_between
    def pan_between(query_from, query_to, options={})
      Query.ensure_valid_query(query_from)
      Query.ensure_valid_query(query_to)

      _pan_between(query_from, query_to, options)
    end

    # Performs a `flick` on the (first) view that matches `query`.
    # @see Calabash::Gestures#flick
    def flick(query, from, to, options={})
      Query.ensure_valid_query(query)

      _flick(query, from, to, {duration: 0.5}.merge(options))
    end

    private

    # @!visibility private
    def _start_app(application, options={})
      abstract_method!
    end

    # @!visibility private
    def _stop_app
      abstract_method!
    end

    # @!visibility private
    def _screenshot(path)
      abstract_method!
    end

    # @!visibility private
    def _install_app(application)
      abstract_method!
    end

    # @!visibility private
    def _ensure_app_installed(application)
      abstract_method!
    end

    # @!visibility private
    def _uninstall_app(identifier)
      abstract_method!
    end

    # @!visibility private
    def _clear_app_data(identifier)
      abstract_method!
    end

    # @!visibility private
    def _port_forward(host_port)
      abstract_method!
    end

    # @!visibility private
    def parse_path_or_app_parameters(path_or_application)
      if path_or_application.is_a?(String)
        Calabash::Application.from_path(path_or_application)
      elsif path_or_application.is_a?(Calabash::Application)
        path_or_application
      else
        raise ArgumentError, "Expected a String or Calabash::Application, got #{path_or_application.class}"
      end
    end

    # @!visibility private
    def parse_identifier_or_app_parameters(identifier_or_application)
      if identifier_or_application.is_a?(String)
        identifier_or_application
      elsif identifier_or_application.is_a?(Calabash::Application)
        identifier_or_application.identifier
      else
        raise ArgumentError, "Expected a String or Calabash::Application, got #{identifier_or_application.class}"
      end
    end

    # @!visibility private
    def _tap(query, options={})
        abstract_method!
    end

    # @!visibility private
    def _double_tap(query, options={})
        abstract_method!
    end

    # @!visibility private
    def _long_press(query, options={})
        abstract_method!
    end

    # @!visibility private
    def _pan(query, from, to, options={})
        abstract_method!
    end

    # @!visibility private
    def _pan_between(query_from, query_to, options={})
      abstract_method!
    end

    # @!visibility private
    def _flick(query, from, to, options={})
        abstract_method!
    end
  end
end
