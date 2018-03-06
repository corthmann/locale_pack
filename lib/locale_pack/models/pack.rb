require 'locale_pack/models/manifest'

module LocalePack
  class Pack

    class << self
      def find_all
        LocalePack.manifest.packs.values.map { |entry| new(entry) }
      end

      def find_by_name(pack_name)
        new(LocalePack.manifest[pack_name])
      end
    end

    attr_accessor :name, :digest, :file_name
    def initialize(options = {})
      @name      = options[:name]
      @digest    = options[:digest]
      @file_name = "#{options[:name]}-#{options[:digest]}.json"
    end

    def path
      "/locale_packs/#{self.file_name}"
    end

    def ==(another_pack)
      self.to_h == another_pack.to_h
    end

    def to_h
      {
        name:      self.name,
        digest:    self.digest,
        file_name: self.file_name,
      }
    end

    def to_json
      self.to_h.to_json
    end
  end
end
