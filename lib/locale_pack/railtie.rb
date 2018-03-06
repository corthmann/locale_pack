require 'locale_pack'

module LocalePack
  class Railtie < Rails::Railtie
    config.locale_pack = ActiveSupport::OrderedOptions.new

    initializer 'locale_pack.configure' do |app|
      # Configrue LocalePack (defaults set in locale_pack.rb)
      LocalePack.configure do |config|
        config.config_path = app.config.locale_pack[:config_path] if app.config.locale_pack.key?(:config_path)
        config.locale_path = app.config.locale_pack[:locale_path] if app.config.locale_pack.key?(:locale_path)
        config.output_path = app.config.locale_pack[:output_path] if app.config.locale_pack.key?(:output_path)
      end
      # Include Helpers in ActionController and ActionView
      ActionController::Base.send :include, LocalePack::PathHelper
      ActionView::Base.send       :include, LocalePack::PathHelper
    end

    rake_tasks do
      load 'tasks/locale_pack.rake'
    end
  end
end
