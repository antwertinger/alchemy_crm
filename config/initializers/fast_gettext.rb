require 'fast_gettext'
FastGettext.add_text_domain 'alchemy_mailings', :path => File.join(File.dirname(__FILE__), '..', '..', 'locale'), :type => :po
FastGettext.default_text_domain = 'alchemy_mailings'
