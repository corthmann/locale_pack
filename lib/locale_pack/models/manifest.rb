require 'securerandom'

module LocalePack
  class Manifest

    MANIFEST_RE = /^\.locale-pack-public-[0-9a-f]{32}.json$/.freeze

    attr_reader :packs

    def initialize
      @packs = {}
    end

    def add(pack)
      @packs[pack.name] = pack.to_json
    end

    def [](name)
      raise ArgumentError, "Locale Pack '#{name}' not found" unless self.packs.key?(name)
      self.packs[name.to_sym]
    end

    def load!
      manifest_file = find_directory_manifest(LocalePack.config.output_path)
      return unless File.exist?(manifest_file)
      @packs = JSON.parse(File.read(manifest_file), symbolize_names: true)
    end

    def save
      File.open(File.join(LocalePack.config.output_path, generate_manifest_path), 'w') do |f|
        f.write(self.packs.to_json)
      end
      true
    end

    def delete
      manifest_file = find_directory_manifest(LocalePack.config.output_path)
      File.delete(manifest_file) if File.exist?(manifest_file)
      @packs = {}
      true
    end

    private

    # Public: Generate a new random public path.
    #
    # Manifests are not intended to be accessed publicly, but typically live
    # alongside public assets for convenience. To avoid being served, the
    # filename is prefixed with a "." which is usually hidden by web servers
    # like Apache. To help in other environments that may not control this,
    # a random hex string is appended to the filename to prevent people from
    # guessing the location. If directory indexes are enabled on the server,
    # all bets are off.
    #
    # Return String path.
    def generate_manifest_path
      ".locale-pack-public-#{SecureRandom.hex(16)}.json"
    end

    # Public: Find or pick a new public filename for target build directory.
    #
    # dirname - String dirname
    #
    # Examples
    #
    #     find_directory_manifest("/app/public/locale_packs")
    #     # => "/app/public/locale_packs/.locale-pack-public-abc123.json"
    #
    # Returns String filename.
    def find_directory_manifest(dirname)
      entries = File.directory?(dirname) ? Dir.entries(dirname) : []
      entry = entries.find { |e| e =~ MANIFEST_RE } ||
          generate_manifest_path
      File.join(dirname, entry)
    end
  end
end
