config_file = "#{::Rails.root.to_s}/config/settings.yml"
raise "Sorry, you must have #{config_file}" unless File.exists?(config_file)

APP_CONFIG = YAML.load_file("#{::Rails.root.to_s}/config/settings.yml")[::Rails.env]
