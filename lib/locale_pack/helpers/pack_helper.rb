require 'locale_pack/models/pack'

module LocalePack
  module PackHelper

    def javascript_locale_pack_tag(name)
      <<-EOS.html_safe
      <script type='text/javascript' src='#{locale_pack_path(name)}' />
      EOS
    end

    def locale_pack_path(name)
      pack = LocalePack::Pack.find_by_name(name)
      pack.path
    end

  end
end
