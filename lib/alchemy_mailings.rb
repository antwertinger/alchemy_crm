if defined?(Rails) && Rails::VERSION::MAJOR == 3
	require 'acts-as-taggable-on'
	require 'rails3-jquery-autocomplete'
	require "prawn"
	require 'delayed_job'
	require 'alchemy_cms'
	require 'alchemy_mailings/version'
	require 'alchemy_mailings/engine'
	require 'alchemy_mailings/newsletter_layout'
	require "alchemy_mailings/seeder"
else
	raise "Alchemy Mailings 2.0 needs Rails 3.0 or higher. You are currently using Rails #{Rails::VERSION::MAJOR}"
end
