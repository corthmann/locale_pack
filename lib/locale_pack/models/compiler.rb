require 'yaml'
require 'locale_pack/models/manifest'
require 'locale_pack/models/pack'

module LocalePack
  class Compiler

    class << self

      def compile!
        manifest = LocalePack::Manifest.new
        # Compile locale packs
        pack_source_files.each do |pack_source|
          pack_data = {}
          source_data = YAML.load_file(pack_source)
          # Iterate files referenced by locale packs.
          (source_data[:files] || source_data['files']).each do |pack_rule|
            locale_file_paths(pack_rule).each { |file_path| pack.deep_merge!(YAML.load_file(file_path)) }
          end
          # Write compiled locale pack
          pack_data = pack_data.to_json
          pack      = LocalePack::Pack.new(
              name: File.basename(pack_source, '.yml'),
              file_digest: Digest::SHA256.hexdigest(pack_data))
          File.open(pack.file_path, 'w') { |f| f.write(pack_data) }
          manifest.add(pack)
        end
        # Write manifest
        File.open(File.join(LocalePack.config.manifest_path, 'locale_pack_manifest.json'), 'w') do |f|
          f.write(manifest.to_json)
        end
      end

      private

      def pack_source_files
        Dir[File.join(LocalePack.config.config_path, '**','*.{yml}').to_s]
      end

      def locale_file_paths(pack_rule)
        LocalePack.config.locale_paths.map do |path|
          Dir[Rails.root.join(path, pack_rule).to_s]
        end.flatten
      end
    end
  end
end
