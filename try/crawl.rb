require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open('http://www.nba.com/players/'))

links = {}
doc.css('a[href]').each do |link_tag|
  text = link_tag.content.strip
  href = link_tag['href']
  if href =~ /\/playerfile\/.+/
    tokens = text.split(/,\s/)
    first = tokens[1]
    
    # Nene
    if first == nil
      first = ''
    end
    last = tokens[0]
    link = 'http://www.nba.com/'+href
    player_doc = Nokogiri::HTML(open(link))
    info = player_doc.css('ul#playerInfoPos li')
    number = info[1].content[1..-1]
    position = info[2].content.strip
  end
end

#puts links