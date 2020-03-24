require 'locale_pack/models/pack'

module LocalePack
  module PackHelper

    def javascript_locale_pack_tag(name, locale: nil)
      <<-EOS.html_safe
      <script type='text/javascript' src='#{locale_pack_path(name, locale: locale)}'></script>
      EOS
    end

    def locale_pack_path(name, locale: nil)
      pack = LocalePack::Pack.find_by_name(name, locale: locale)
      pack.path
    end

    class Reader
      include Singleton
      include LocalePack::PackHelper

      def initialize
        # memoized packs - the file path is used as the key and the file content as the value
        @locale_packs = {}
        @output_path = LocalePack.config&.output_path
      end

      # returns the locale pack's file content
      def read_locale_pack(name, locale: nil)
        pack = LocalePack::Pack.find_by_name(name, locale: locale)
        locale_file_path = File.join(@output_path, pack.file_name)

        if !@locale_packs.key?(locale_file_path) && File.exists?(locale_file_path)
          locale_file = File.file?(locale_file_path)
          return '' unless locale_file
          locale_pack_content = File.read(locale_file_path)

          @locale_packs[locale_file_path] = locale_pack_content
        end

        @locale_packs[locale_file_path]
      end
    end

  end
end
