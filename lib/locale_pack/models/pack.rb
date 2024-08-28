require 'locale_pack/models/manifest'

module LocalePack
  class Pack

    class << self
      def find_all
        LocalePack.manifest.packs.values.map { |entry| new(entry) }
      end

      def find_by_name(pack_name, locale: nil)
        name = (locale ? "#{pack_name}_#{locale}" : pack_name)
        new(LocalePack.manifest[name])
      end
    end

    attr_accessor :id, :name, :digest, :file_name, :locale
    def initialize(options = {})
      @id        = (options[:locale] ? "#{options[:name]}_#{options[:locale]}" : options[:name])
      @name      = options[:name]
      @digest    = options[:digest]
      @locale    = options[:locale]
      @file_name = "#{@id}-#{options[:digest]}"
    end

    def path(extension: 'js')
      return ArgumentError, "invalid locale pack file extension" unless %w(js json).include?(extension)

      "/locale_packs/#{self.file_name}.#{extension}"
    end

    def json_content
      return @content if defined?(@content) && @content

      json_path = File.join(LocalePack.config.output_path, "#{self.file_name}.json")
      return '' unless File.exist?(json_path)

      @content = File.read(json_path)
    end

    def ==(another_pack)
      self.to_h == another_pack.to_h
    end

    def to_h
      {
        id:        self.id,
        name:      self.name,
        digest:    self.digest,
        file_name: self.file_name,
        locale:    self.locale
      }
    end

    def to_json
      self.to_h.to_json
    end
  end
end
