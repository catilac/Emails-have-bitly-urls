# EmailsHaveBitlyUrls

module EmailsHaveBitlyUrls
  def self.included(base)
    base.extend Enhancement::BitlyUrls
    base.send :include, Enhancement::Base
  end
  
  module Enhancement
    module BitlyUrls
      def compress_the_urls(mail)
        bitly_regex = /http:\/\/bit\.ly\/\w{1,6}(?!\w+)/
        
        begin
          bitly = Bitly.new(BITLY[:user], BITLY[:api_key])
        rescue
          bitly = nil
        end
        
        # Iterate through all parts and replace all urls there as well.
        mail.parts.collect! do |part|
          url_hash = {}
          urls = []
                    
          part.body.scan(URI::regexp(['http', 'https'])) do |m|
            urls << $&
          end
          
          # Delete all URLS that are already bit.ly compressed.
          urls.delete_if { |u| u =~ bitly_regex }
          
          begin
            bitly_urls = bitly.shorten(urls)
            urls = bitly_urls
          rescue Exception => e
          end
          
          urls.each do |u|
            if Bitly::Url === u
              url_hash[u.long_url] = u.short_url
            else
              url_hash[u] = u
            end
          end
          
          
          url_hash.delete "http://www.w3.org/1999/xhtml"
                    
          url_hash.each do |long, short|
            long_regex = Regexp.new(/#{Regexp.quote long}\/?(?![^ \{\}\^'"<>\[\]]+)/)
            part.body = [normalize_new_lines(part.body.gsub(long_regex, short))].pack("M*")
          end
          part
        end
        mail
      end
    end
    
    module Base
      include BitlyUrls
      include ActionMailer
      
      def self.included(base)
        base.alias_method_chain :create_mail, :bitly
      end
      
      def create_mail_with_bitly
        mail = create_mail_without_bitly
        
        unless mail.parts.empty?
          mail.content_type = "multipart/alternative" if mail.content_type !~ /^multipart/
          ordered_parts = sort_parts(mail.parts, ActionMailer::Base.default_implicit_parts_order)
          mail.parts.size.times { mail.parts.shift }
          ordered_parts.size.times { mail.parts << ordered_parts.shift }
        end
        
        compress_the_urls(mail)
      end
      
    end
  end
end
