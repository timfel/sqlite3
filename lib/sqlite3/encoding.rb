module SQLite3
  class Encoding
    class << self
      def find(encoding)
        enc = encoding.to_s
        if enc.downcase == "utf-16"
          native_utf_16
        else
          ::Encoding.find(enc).tap do |e|
            if utf_16?(e) && e != native_utf_16
              raise ArgumentError, "requested to use byte order different than native"
            end
          end
        end
      end

      def utf_16?(str_or_enc)
        enc = str_or_enc.kind_of?(::Encoding) ? str_or_enc : str_or_enc.encoding
        [utf_16le, utf_16be].include?(enc)
      end

      def native_utf_16
        "Ruby".unpack("i")[0] == 2036495698 ? utf_16le : utf_16be
      end

      def utf_16le
        ::Encoding::UTF_16LE
      end

      def utf_16be
        ::Encoding::UTF_16BE
      end
    end
  end
end
