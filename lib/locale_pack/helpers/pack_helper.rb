require 'locale_pack/models/pack'

module LocalePack
  module PackHelper

    def locale_pack_js
      <<-EOS.html_safe
      <script type='text/javascript'>
          var localePacks = {};
          function loadTranslationPack(path, async, callback) {
            var xobj = new XMLHttpRequest();
            xobj.overrideMimeType("application/json");
            xobj.open('GET', path, async);
            xobj.onreadystatechange = function () {
                  if (xobj.readyState == 4 && xobj.status == "200") {
                    // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
                    callback(xobj.responseText);
                  }
            };
            xobj.send(null); 
          }
      </script>
      EOS
    end

    def locale_pack_path(name)
      pack = LocalePack::Pack.find_by_name(name)
      pack.path
    end

    def locale_pack_tag(name, async: false)
      <<-EOS.html_safe
      <script type='text/javascript'>
          loadTranslationPack('#{locale_pack_path(name)}', #{async}, function(response) {
            window.localePack = JSON.parse(response);
          });
      </script>
      EOS
    end

  end
end
