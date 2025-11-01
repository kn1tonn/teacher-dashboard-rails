require "uri"
module ApplicationHelper
  def safe_external_url(raw_url)
    return if raw_url.blank?
    url = raw_url.to_s.strip
    uri = URI.parse(url)
    url if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    nil
  end
endmodule ApplicationHelper
end
