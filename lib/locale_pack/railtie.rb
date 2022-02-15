require 'locale_pack'
require 'locale_pack/helpers/pack_helper'
require 'locale_pack/models/pack'
require 'locale_pack/models/pack_file'

module LocalePack
  class Railtie < Rails::Railtie
    config.locale_pack = ActiveSupport::OrderedOptions.new

    # Load the manifest once in production and before every request in development.
    config.to_prepare do
      LocalePack.manifest.load!
    end

    initializer 'locale_pack.configure' do |app|
      # Configure LocalePack (defaults set in locale_pack.rb)
      LocalePack.configure do |config|
        config.config_path = app.config.locale_pack[:config_path] if app.config.locale_pack.key?(:config_path)
        config.locale_path = app.config.locale_pack[:locale_path] if app.config.locale_pack.key?(:locale_path)
        config.output_path = app.config.locale_pack[:output_path] if app.config.locale_pack.key?(:output_path)
        config.export_locales = export_locales(app)
      end
      # Include Helpers in ActionController and ActionView
      ActionController::Base.send :include, LocalePack::PackHelper
      ActionView::Base.send       :include, LocalePack::PackHelper
    end

    initializer 'locale_pack.development_compile_on_start', after: 'locale_pack.configure' do
      if Rails.env.development?
        Rails.logger.info('LocalePack: Deleting all existing compiled packs...')
        LocalePack.manifest.load!
        LocalePack.manifest.packs.each do |_, pack|
          File.delete(File.join(LocalePack.config.output_path, pack[:file_name])) if File.exist?(File.join(LocalePack.config.output_path, pack[:file_name]))
        end
        Rails.logger.info('LocalePack: Compiling all packs...')
        manifest = LocalePack::Manifest.new
        LocalePack::PackFile.find_all.each do |pack_file|
          pack_file.save
          pack_file.packs.each do |pack|
            manifest.add(pack)
          end
        end
        manifest.save
        Rails.logger.info('LocalePack: Finished compiling all packs.')
        LocalePack.manifest.load!
      end
    end

    initializer 'locale_pack.development_register_listeners', after: 'locale_pack.development_compile_on_start' do
      if defined?(Listen) && Rails.env.development?
        # Register and start compilation listeners
        LocalePack.listeners << pack_listener
        LocalePack.listeners << dependency_listener
        LocalePack.listeners.each  { |listener| listener.start }
      end
    end

    rake_tasks do
      load 'locale_pack/tasks/locale_pack.rake'
    end

    private

    def export_locales(app)
      fallback_locales = app.config&.i18n&.fallbacks
      available_locales = app.config&.i18n&.available_locales

      if fallback_locales.is_a?(Array)
        available_locales.union(fallback_locales)
      elsif fallback_locales.is_a?(Hash)
        available_locales.union(fallback_locales.values.flatten)
      else
        available_locales if fallback_locales.nil?
      end
    end

    def pack_listener
      Listen.to(LocalePack.config.config_path, only: /\.yml$/) do |modified, added, removed|
        added.each do |f|
          compile_pack(f)
        end
        modified.each do |f|
          remove_pack(f)
          compile_pack(f)
        end
        removed.each do |f|
          remove_pack(f)
        end
        # Save manifest to the system and load the manifest into memory.
        LocalePack.manifest.save
        LocalePack.manifest.load!
      end
    end

    def dependency_listener
      Listen.to(LocalePack.config.locale_path, only: /\.yml$/) do |modified, added, removed|
        compilation_list = Set.new
        # Identify which Locale Packs that need to be re-compiled.
        LocalePack::PackFile.find_all.each do |pack_file|
          (added+modified).each do |f|
            compilation_list << pack_file.path if pack_file.files(raw: true).include?(f)
          end
          removed.each { |f| compilation_list << pack_file.path if pack_file.files.include?(f) }
        end
        # Re-compile Locale Packs
        compilation_list.each do |path|
          remove_pack(path)
          compile_pack(path)
        end
        # Save manifest to the system and load the manifest into memory.
        if compilation_list.any?
          LocalePack.manifest.save
          LocalePack.manifest.load!
        end
      end
    end

    def compile_pack(f)
      Rails.logger.info("LocalePack: Compiling pack file '#{f}'")
      path = f.sub(LocalePack.config.config_path, '')
      pack_file = LocalePack::PackFile.new(path: path)
      pack_file.save
      pack_file.packs.each do |pack|
        LocalePack.manifest.add(pack)
      end
    end

    def remove_pack(f)
      Rails.logger.info("LocalePack: Removing compiled pack file for '#{f}'")
      path = f.sub(LocalePack.config.config_path, '')
      pack_name = File.basename(path, '.yml')
      pack_names = [pack_name] + LocalePack.config.export_locales.map do |locale|
        "#{pack_name}_#{locale}"
      end
      pack_names.each do |name|
        pack = LocalePack::Pack.find_by_name(name)
        LocalePack.manifest.remove(pack)
        File.delete(File.join(LocalePack.config.output_path, pack.file_name)) if File.exist?(File.join(LocalePack.config.output_path, pack.file_name))
      end
    end
  end
end
