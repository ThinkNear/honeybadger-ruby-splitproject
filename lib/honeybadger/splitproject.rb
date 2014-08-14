module Honeybadger
  module Splitproject
    
    class << self
      def add_notifiers_for_team(team_postfix, api_key)
        raise "Blank team postfix given for Honeybadger." if team_postfix.nil? || team_postfix.strip.length == 0
        raise "Blank Honeybadger API key given for team #{team_postfix}" if api_key.nil? || api_key.strip.length == 0
        
        raise "Team postfix #{team_postfix} already setup with honeybadger" if Honeybadger.respond_to?("notify_#{team_postfix}")
        
        add_team_specific_notifier(team_postfix, api_key)
        add_team_specific_detailed_notifier(team_postfix)
      end
      
      private
      
      # this will add a notify_<teamname> method.
      def add_team_specific_notifier(team_postfix, api_key)
        Honeybadger.instance_eval do
          # works even if an options hash is passed as first argument
          define_singleton_method("notify_#{team_postfix}") do |exception, options|
            options ||= {}  # this is how you specify default params in this way
            notify(exception, options.merge({ api_key: api_key }))
          end
        end
      end
    
      # this will add a notify_detailed_<teamname> method.
      def add_team_specific_detailed_notifier(team_postfix)
        Honeybadger.instance_eval do
          define_singleton_method("notify_detailed_#{team_postfix}") do |error_class, error_message, parameters|
            parameters ||= {} # this is how you specify default params in this way
            options = parameters.merge({ error_message: error_message })
            send("notify_#{team_postfix}", { error_class: error_class }, options)
          end
        end
      end
      
    end
  end
end
