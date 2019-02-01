require 'locale_pack/models/pack'

module LocalePack
  module PackHelper

    def javascript_locale_pack_tag(name, locale: nil)
      <<-EOS.html_safe
      <script type='text/javascript' src='#{locale_pack_path(name, locale: locale)}' />
      EOS
    end

    def locale_pack_path(name, locale: nil)
      pack = LocalePack::Pack.find_by_name(name, locale: locale)
      pack.path
    end

  end
end
