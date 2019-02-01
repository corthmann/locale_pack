require 'locale_pack/version'
require 'locale_pack/railtie' if defined?(Rails)
require 'locale_pack/helpers/pack_helper'
require 'locale_pack/models/manifest'
require 'locale_pack/models/pack'
require 'locale_pack/models/pack_file'

module LocalePack
  class Config

    attr_accessor :output_path, :config_path, :locale_path, :export_locales

    def initialize
      if defined?(Rails)
        @config_path = File.join(Rails.root, 'config', 'locale_packs')
        @locale_path = File.join(Rails.root, 'config', 'locales')
        @output_path = File.join(Rails.root, 'public', 'locale_packs')
      end
      @export_locales = []
    end
  end

  def self.config
    @@config ||= Config.new
  end

  def self.manifest
    @@manifest ||= LocalePack::Manifest.new
  end

  def self.listeners
    @@listeners ||= []
  end

  def self.configure
    yield self.config
  end

  def self.reset!
    @@config   = nil
    @@manifest = nil
  end
end
