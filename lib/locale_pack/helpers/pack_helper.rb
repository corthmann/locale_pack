require 'locale_pack/models/pack'

module LocalePack
  module PackHelper

    def javascript_locale_pack_tag(name, locale: nil)
      <<-EOS.html_safe
      <script type='text/javascript' src='#{locale_pack_path(name, locale: locale, extension: 'js')}'></script>
      EOS
    end

    def locale_pack_path(name, locale: nil, extension: 'js')
      pack = LocalePack::Pack.find_by_name(name, locale: locale)
      pack.path(extension: extension)
    end

    def locale_pack_json_content(name, locale: nil)
      pack = LocalePack::Pack.find_by_name(name, locale: locale)
      pack.json_content
    end
  end
end
