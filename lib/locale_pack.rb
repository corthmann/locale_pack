require 'locale_pack/version'
require 'locale_pack/railtie' if defined?(Rails)
require 'locale_pack/models/manifest'
require 'locale_pack/models/pack'
require 'locale_pack/models/pack_file'

module LocalePack
  class Config

    attr_accessor :output_path, :config_path, :locale_path

    def initialize
      if defined?(Rails)
        @config_path   = Rails.root.join('config', 'locale_pack')
        @locale_path   = Rails.root.join('config', 'locales')
        @output_path   = Rails.root.join('public', 'locale_packs')
      end
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
