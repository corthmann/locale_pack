require 'digest/sha2'
require 'locale_pack/models/pack'

module LocalePack
  class PackFile

    class << self
      def find_all
        Dir[File.join(LocalePack.config.config_path, '**', '*.yml')].map do |f|
          new(path: f.sub(LocalePack.config.config_path, ''))
        end
      end

      def find_by_name(name)
        find_all.detect { |file_pack| file_pack.name.to_s == name.to_s} ||
            (raise ArgumentError, "Locale Pack with name '#{name}' not found")
      end
    end

    attr_accessor :name, :path
    def initialize(options = {})
      unless File.exist?(File.join(LocalePack.config.config_path, options[:path]))
        raise ArgumentError, "Locale Pack with path '#{options[:path]}' not found"
      end
      @name = File.basename(options[:path], '.yml')
      @path = options[:path]
    end

    def compiled?
      File.exist?(compiled_file_path)
    end

    def destroy
      return unless compiled?
      File.delete(compiled_file_path)
    end

    def digest
      Digest::SHA256.hexdigest(data)
    end

    def files(raw: false)
      return (file_dependencies+pack_file_dependencies).uniq if raw
      @files ||= (file_dependencies+pack_file_dependencies).uniq
    end

    def packs
      pack_list = LocalePack.config.export_locales.map do |locale|
        LocalePack::Pack.new(name: self.name, digest: self.digest, locale: locale)
      end
      pack_list << LocalePack::Pack.new(name: self.name, digest: self.digest)
      pack_list
    end

    def save
      LocalePack.config.export_locales.each do |locale|
        File.open(compiled_file_path(locale: locale), 'w') do |f|
          f.write("var localePack = #{data_for_locale(locale)};")
        end
      end
      File.open(compiled_file_path, 'w') do |f|
        f.write("var localePack = #{data};")
      end
    end

    private

    def pack_source
      YAML.load_file(File.join(LocalePack.config.config_path, self.path))
    end

    def pack_file_dependencies
      (pack_source[:packs] || []).map do |f|
        LocalePack::PackFile.new(path: f).files
      end.flatten
    end

    def file_dependencies
      (pack_source[:files] || []).map do |f|
        Dir[File.join(LocalePack.config.locale_path, f)]
      end.flatten
    end

    def compiled_file_path(locale: nil)
      file_name = (locale ?
                       "#{self.name}_#{locale}-#{self.digest}.js" :
                       "#{self.name}-#{self.digest}.js")
      File.join(LocalePack.config.output_path, file_name)
    end

    def data_for_locale(locale)
      { locale.to_sym => JSON.parse(data, symbolize_names: true)[locale.to_sym] }.to_json
    end

    def data
      return @data if defined?(@data)
      h = {}
      self.files.each do |f|
        file_data = YAML.load_file(f)
        unless file_data
          if defined?(Rails)
            Rails.logger.error("LocalePack: Pack '#{self.name}' skipping dependency '#{f}' because the file is invalid.")
          end
          next
        end
        h.deep_merge!(file_data)
      end
      @data = h.to_json
    end
  end
end
