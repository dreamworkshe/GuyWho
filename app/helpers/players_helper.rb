require "net/https"
require "uri"
require "json"

module PlayersHelper
  def getNews(query)
    url = URI::encode("https://ajax.googleapis.com/ajax/services/search/news?v=1.0&q=#{query}")
    uri = URI.parse(url)

    # Set http object, using ssl
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Send request and get results
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    results = JSON.parse(response.body)["responseData"]["results"]
    results = results.map do |news|
      {:url => news["unescapedUrl"], :title => news["titleNoFormatting"]}
    end
    return results
  end

end
