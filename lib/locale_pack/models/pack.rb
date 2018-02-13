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

    attr_reader :name, :file_digest, :file_extension, :file_name, :file_path
    def initialize(options = {})
      @name           = options[:name]
      @file_digest    = options[:file_digest]
      @file_name      = "#{options[:name]}-#{options[:file_digest]}"
      @file_path      = "#{LocalePack.config.output_path}/#{@file_name}.json"
    end

    def path
      "/locale_packs/#{self.file_name}.json"
    end

    def to_json
      {
          name:        self.name,
          file_digest: self.file_digest,
          file_name:   self.file_name,
          file_path:   self.file_path
      }.to_json
    end
  end
end
