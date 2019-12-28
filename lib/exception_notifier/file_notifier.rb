require "exception_notification"
require "action_dispatch"
require "active_support/core_ext/hash"
require "socket"
require 'logger'
require 'json'

module ExceptionNotifier
  class FileNotifier < BaseNotifier
    include ExceptionNotifier::BacktraceCleaner

    def initialize(options={})
      filename     = options[:filename]   || "log/error.log"
      shift_age    = options[:shift_age]  || 0
      shift_size   = options[:shift_size] || nil

      @logger_options     = [filename, shift_age, shift_size]
      @formatter          = -> (_, _, _, message) { message + "\n" }
    end

    def call(exception=nil, options={})
      append_log exception_message(options[:env], exception, options)
    end

    def append_log(message)
      log = ::Logger.new(*@logger_options)
      log.formatter = @formatter
      error_log = generate_json(message)
      log.error(error_log)
      log.close
    end

    def generate_json(message)
      ::JSON.generate(deep_encode(message))
    end

    def exception_message(env, exception, options={})
      return error_message(exception) unless exception.is_a?(Exception)

      if env.present?
        exception_notification(options[:env], exception, options)
      else
        background_exception_notification(exception, options)
      end
    end

    def exception_notification(env, exception, options)
      @env        = env
      @exception  = exception
      @options    = options.reverse_merge(@env['exception_notifier.options'] || {}).symbolize_keys
      @kontroller = @env['action_controller.instance'] || MissingController.new
      @request    = ::ActionDispatch::Request.new(@env)
      @backtrace  = exception.backtrace ? clean_backtrace(exception) : []
      @timestamp  = ::Time.current
      @data       = (@env['exception_notifier.exception_data'] || {}).merge(options[:data] || {})

      render_notice
    end

    def background_exception_notification(exception, options)
      @exception = exception
      @options   = options.symbolize_keys
      @backtrace = exception.backtrace || []
      @timestamp = ::Time.current
      @data      = options[:data] || {}
      @env = @kontroller = nil

      render_notice
    end

    def error_message(exception)
      {
        message:           '[FATAL] NO EXCEPTION GIVEN: Please provide Exception as argument',
        exception:         exception.try(:to_s),
        timestamp:         ::Time.current,
      }
    end

    def render_notice
      set_data_variables

      exception_details = {
        exception:         @exception.class,
        controller:        @kontroller.present? ? @kontroller.controller_name : '[BACKGROUND]',
        action:            @kontroller.present? ? @kontroller.action_name : '[BACKGROUND]',
        exception_message: @exception.message,

        timestamp:         @timestamp,
        server:            ::Socket.gethostname,
        rails_root:        (defined?(::Rails) && ::Rails.respond_to?(:root) ) ? ::Rails.root : nil,
        process:           $$,
        backtrace:         @backtrace,
      }

      if @env.present?
        exception_details.merge!({
          url:               @request.url,
          http_method:       @request.request_method,
          ip_address:        @request.remote_ip,
          parameters:        (@request.filtered_parameters.inspect rescue "[NOT ENCODABLE]"),
          session_id:        (@request.ssl? ? "[FILTERED]" : @request.session['session_id'] || (@request.env["rack.session.options"] and @request.env["rack.session.options"][:id])),
          session_data:      @request.session.to_hash,
        })
        filtered_env = @request.filtered_env
        filtered_env.sort_by { |key, _| key.to_s }.each do |key, value|
          exception_details[key] = value
        end
      end

      exception_details.merge!({
        data:              @data,
      })

      exception_details
    end

    class MissingController
      def controller_name
        '[NO CONTROLLER]'
      end
      def action_name
        '[NO CONTROLLER]'
      end
      def method_missing(*args, &block)
      end
    end

    def set_data_variables
      @data.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def deep_encode(obj)
      case obj
      when Array
        obj.map { |o| deep_encode(o) }
      when Hash
        deep_encode(obj.to_a).to_h
      when String
        encode_to_utf8(obj)
      else
        obj.respond_to?(:to_s) ? encode_to_utf8(obj.to_s) : '[NOT ENCODABLE]'
      end
    end

    def encode_to_utf8(str)
      quick_sanitization(str).encode(::Encoding.find('UTF-8'), invalid: :replace, undef: :replace, replace: '?')
    end

    def quick_sanitization(str) # stringify any random objects in a safe (and convenient) manner
      str.inspect.gsub(/\A\"(.*)\"\z/,'\1')
    end
  end
end
