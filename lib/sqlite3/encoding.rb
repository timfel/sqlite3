module SQLite3
  class Encoding

    if RUBY_VERSION =~ /1.8/
      # Add missing methods and constants for 1.8
      class ::String
        def force_encoding(enc); self; end
        def encode(enc); self; end
        def encoding; $KCODE; end
      end

      ASCII_8BIT = "N"
      US_ASCII = "N"
      UTF_8 = "U"
      UTF_16BE = "N"
      UTF_16LE = "N"
      ::Encoding = Encoding
    end

    class << self
      def find(encoding)
        enc = encoding.to_s
        if enc.downcase == "utf-16"
          utf_16native
        else
          return find18(enc) if Encoding == ::Encoding
          ::Encoding.find(enc).tap do |e|
            if utf_16?(e) && e != utf_16native
              raise ArgumentError, "requested to use byte order different than native"
            end
          end
        end
      end

      def find18(enc)
        if ["us-ascii", "utf-8"].include? enc.downcase
          send(enc.downcase.sub("-", "_").to_sym)
        else
          raise ArgumentError, "requested encoding not supported on #{RUBY_VERSION}"
        end
      end

      def utf_16?(str_or_enc)
        enc = str_or_enc.kind_of?(::Encoding) ? str_or_enc : str_or_enc.encoding
        [utf_16le, utf_16be].include?(enc)
      end

      def utf_16native
        "Ruby".unpack("i")[0] == 2036495698 ? utf_16le : utf_16be
      end

      def us_ascii
        ::Encoding::US_ASCII
      end

      def utf_8
        ::Encoding::UTF_8
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
