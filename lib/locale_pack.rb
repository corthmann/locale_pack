require 'locale_pack/version'
require 'locale_pack/railtie' if defined?(Rails)
require 'locale_pack/models/manifest'

module LocalePack
  class Config

    attr_accessor :output_path, :config_path, :locale_paths, :manifest_path

    def initialize
      @config_path   = Rails.root.join('config', 'locale_pack')
      @locale_paths  = [Rails.root.join('config', 'locales')]
      @manifest_path = Rails.root.join('public')
      @output_path   = Rails.root.join('public', 'locale_packs')
    end
  end

  def self.config
    @@config ||= Config.new
  end

  def self.manifest
    @@manifest ||= LocalePack::Manifest.new
  end

  def self.configure
    yield self.config
  end

  def self.reset!
    @@config   = nil
    @@manifest = nil
  end
end
