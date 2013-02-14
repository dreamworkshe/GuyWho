namespace :player do
  require 'nokogiri'
  require 'open-uri'
  task :build => :environment do
    doc = Nokogiri::HTML(open('http://www.nba.com/players/'))
    link_tags = doc.css('a[href]')
    counter = 0
    link_tags.each do |link_tag|
      counter += 1
      text = link_tag.content.strip
      href = link_tag['href']
      if href =~ /\/playerfile\/.+/
        tokens = text.split(/,\s/)
        last = tokens[0]
        first = tokens[1]
        # Nene
        if first == nil
          first = last
        end
        link = 'http://www.nba.com'+href
        player_doc = Nokogiri::HTML(open(link))
        info = player_doc.css('ul#playerInfoPos li')
        number = info[1].content[1..-1].to_i
        position = info[2].content.strip

        p = Player.new(:first_name => first, :last_name => last, :number => number, :position => position, :url => link)
        p.save!

        puts first + " " + last + " finished. (" + counter.to_s + " of " + link_tags.length.to_s + ")"
      end
    end

  end

  task :test => :environment do
    #p = Player.new(:first_name=>'123')
    #p.save!
  end
end