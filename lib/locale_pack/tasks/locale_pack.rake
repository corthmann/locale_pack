require 'rake'
require 'locale_pack/models/manifest'
require 'locale_pack/models/pack_file'

namespace :locale_pack do
  namespace :compile do
    desc 'Compile all locale packs'
    task :all, [] => :environment do
      manifest = LocalePack::Manifest.new
      LocalePack::PackFile.find_all.each do |pack_file|
        pack_file.save
        pack_file.packs.each do |pack|
          manifest.add(pack)
        end
      end
      manifest.save
    end

    desc 'Compile the locale pack with the given name'
    task :one, [:name] => :environment do |_, args|
      name = args['name'].to_sym
      raise ArgumentError, 'Missing argument "name"' unless name && !name.empty?
      manifest = LocalePack::Manifest.new
      manifest.load!
      pack_file = LocalePack::PackFile.find_by_name(name)
      pack_file.save
      pack_file.packs.each do |pack|
        manifest.add(pack)
      end
      manifest.save
    end
  end
end
