class TeamFilter
  def filter(options)
    team = options[:tn_team] || Thread.current[:tn_honeybadger_team]

    unless team.nil?
      env_key = KeyHelpers.env_key(team.to_s)
      options[:api_key] = ENV[env_key]
    end
  end
end