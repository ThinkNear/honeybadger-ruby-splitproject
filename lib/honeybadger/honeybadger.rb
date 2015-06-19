require 'honeybadger'
require 'honeybadger/key_helpers'

module Honeybadger
  class << self
    def notify_detailed(error_class, error_message, parameters = {})
      # force class to be to string'd to prevent HB stackoverflow
      notify(error_class: error_class.to_s, error_message: error_message, parameters: parameters)
    end

    #all calls to notify should go through this method
    def notify_base(exception_or_opts, options = {})
      options.merge!(exception: exception_or_opts) if exception_or_opts.is_a?(Exception)
      options.merge!(exception_or_opts.to_hash) if exception_or_opts.respond_to?(:to_hash)
      Honeybadger::Splitproject.filters.each do |filter|
        filter.filter(options)
      end
      notify_super(options)
    end

    alias_method :notify_super, :notify
    alias_method :notify, :notify_base

    def set_team(team)
      Thread.current[:tn_honeybadger_team] = team.to_sym
    end

    def clear_team
      Thread.current[:tn_honeybadger_team] = nil
    end
  end
end