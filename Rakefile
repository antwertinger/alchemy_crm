require 'rake'
Dir.glob(File.dirname(__FILE__) + "/lib/tasks/*.rake").each do |rake_file|
  import rake_file
end

namespace :gettext do
  def load_gettext
    require 'gettext'
    require 'gettext/tools'
  end

  desc "Create mo-files for L10n"
  task :pack do
    load_gettext
    GetText.create_mofiles(:verbose => true, :po_root => "locale", :mo_root => "locale")
  end

  desc "Update pot/po files."
  task :find do
    load_gettext
    $LOAD_PATH << File.join(File.dirname(__FILE__),'..','alchemy','plugins','gettext_i18n_rails','lib')
    require 'gettext_i18n_rails/haml_parser'

    if GetText.respond_to? :update_pofiles_org
      GetText.update_pofiles_org(
        "mailings",
        Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,rjs}"),
        "version 2.0",
        :po_root => 'locale',
        :msgmerge=>['--sort-output']
      )
    else #we are on a version < 2.0
      puts "install new GetText with gettext:install to gain more features..."
      #kill ar parser...
      require 'gettext/parser/active_record'
      module GetText
        module ActiveRecordParser
          module_function
          def init(x);end
        end
      end

      #parse files.. (models are simply parsed as ruby files)
      GetText.update_pofiles(
        "mailings",
        Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,rjs}"),
        "version 2.0",
        'locale'
      )
    end
  end

  # This is more of an example, ignoring
  # the columns/tables that mostly do not need translation.
  # This can also be done with GetText::ActiveRecord
  # but this crashed too often for me, and
  # IMO which column should/should-not be translated does not
  # belong into the model
  #
  # You can get your translations from GetText::ActiveRecord
  # by adding this to you gettext:find task
  #
  # require 'active_record'
  # gem "gettext_activerecord", '>=0.1.0' #download and install from github
  # require 'gettext_activerecord/parser'
  desc "write the locale/model_attributes.rb"
  task :store_model_attributessss => :environment do
    FastGettext.silence_errors
    require 'gettext_i18n_rails/model_attributes_finder'
    storage_file = 'locale/model_attributes.rb'
    puts "writing model translations to: #{storage_file}"
    GettextI18nRails.store_model_attributes(
      :to=>storage_file,
      :ignore_columns=>[/_id$/,'id','type','created_at','updated_at'],
      :ignore_tables=>[/^sitemap_/,/_versions$/,'schema_migrations']
    )
  end
end
