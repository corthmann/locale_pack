module LocalePack
  class Manifest

    MANIFEST_FILE_NAME = 'locale_pack_manifest.json'.freeze

    attr_reader :packs

    def initialize(load_from_file: true)
      if load_from_file
        load!
      else
        @packs = {}
      end
    end

    def add(pack)
      @packs[pack.name] = pack.to_json
    end

    def [](name)
      raise ArgumentError, "Locale Pack '#{name}' not found" unless self.packs.key?(name)
      self.packs[name.to_sym]
    end

    def to_json
      @packs.to_json
    end

    private

    def load!
      @packs = JSON.parse(File.read(
        File.join(LocalePack.config.manifest_path, MANIFEST_FILE_NAME)
      ), symbolize_names: true)
    end
  end
end
