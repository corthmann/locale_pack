require 'locale_pack/models/pack'

module LocalePack
  module PackHelper

    def javascript_locale_pack_tag(name, locale: nil)
      <<-EOS.html_safe
      <script type='text/javascript' src='#{locale_pack_path(name, locale: locale)}'></script>
      EOS
    end

    # returns the locale pack's file content
    def read_locale_pack(name, locale: nil)
      path = "public#{locale_pack_path(name, locale: locale)}"

      return unless File.file?(path)
      locale_pack_content = File.read(path)

      raw(locale_pack_content)
    end

    def locale_pack_path(name, locale: nil)
      pack = LocalePack::Pack.find_by_name(name, locale: locale)
      pack.path
    end

  end
end
