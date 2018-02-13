require 'rake'

namespace :locale_pack do
  desc 'Compile locale packs'
  task :compile, [:pack_name] => :environment do |_, args|
    raise "Missing 'pack_name' parameter" if (args['pack_name'].nil? || args['pack_name'].empty?)
    pack_name = args['pack_name'].to_sym


    manifest = {}
    # Precompile locale packs
    Dir[Rails.root.join('config','locale_packs', '**','*.{yml}').to_s].each do |locale_pack_path|
      pack = {}
      # Iterate files referenced by locale packs.
      YAML.load_file(locale_pack_path)[:files].each do |locale_file_path|
        Dir[Rails.root.join('config', 'locales', locale_file_path).to_s].each do |translation_file_path|
          pack.deep_merge!(YAML.load_file(translation_file_path))
        end
      end
      # Write precompiled locale pack
      pack_data      = pack.to_json
      pack_digest    = Digest::SHA256.hexdigest(pack_data)
      pack_name      = File.basename(locale_pack_path, '.yml')
      pack_file_name = "#{pack_name}-#{pack_digest}"
      pack_file_path = "#{Rails.root}/public/locale_packs/#{pack_file_name}.json"
      manifest[pack_name] = {
          file_digest: pack_digest,
          file_extension: 'json',
          file_name: pack_file_name,
          file_path: pack_file_path,
          name: pack_name
      }
      f = File.new(pack_file_path, 'w')
      f.write(pack_data)
      f.close
    end
    # Write manifest
    manifest_file = File.new(File.join(Rails.root, 'public', 'locale_pack_manifest.json'), 'w')
    manifest_file.write(manifest.to_json)
    manifest_file.close



  end
end
