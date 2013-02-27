namespace :player do
  require 'nokogiri'
  require 'open-uri'

  # TODO: downcase in searchable
  @TEAMS = {'BOS' => ['Boston', 'Celtics'],
            'BKN' => ['Brooklyn', 'Nets'],
            'NYK' => ['New York', 'Knicks'],
            'PHI' => ['Philadelphia', '76ers'],
            'TOR' => ['Toronto', 'Raptors'],
            'DAL' => ['Dallas', 'Mavericks'],
            'HOU' => ['Houston', 'Rockets'],
            'MEM' => ['Memphis', 'Grizzlies'],
            'NOH' => ['New Orleans', 'Hornets'],
            'SAS' => ['San Antonio', 'Spurs'],
            'CHI' => ['Chicago', 'Bulls'],
            'CLE' => ['Cleveland', 'Cavaliers'],
            'DET' => ['Detroit', 'Pistons'],
            'IND' => ['Indiana', 'Pacers'],
            'MIL' => ['Milwaukee', 'Bucks'],
            'DEN' => ['Denver', 'Nuggets'],
            'MIN' => ['Minnesota', 'Timberwolves'],
            'POR' => ['Portland', 'Trail Blazers'],
            'OKC' => ['Oklahoma City', 'Thunder'],
            'UTA' => ['Utah', 'Jazz'],
            'ATL' => ['Atlanta', 'Hawks'],
            'CHA' => ['Charlotte', 'Bobcats'],
            'MIA' => ['Miami', 'Heat'],
            'ORL' => ['Orlando', 'Magic'],
            'WAS' => ['Washington', 'Wizards'],
            'GSW' => ['Golden State', 'Warriors'],
            'LAC' => ['Los Angeles', 'Clippers'],
            'LAL' => ['Los Angeles', 'Lakers'],
            'PHX' => ['Phoenix', 'Suns'],
            'SAC' => ['Sacramento', 'Kings']}
  
  task :build => :environment do
    doc = Nokogiri::HTML(open('http://www.nba.com/players/'))
    link_tags = doc.css('a[href]')
    
    # get all player links
    playerlinks = []
    link_tags.each do |link_tag|
      href = link_tag['href']
      if href =~ /\/playerfile\/.+/
        text = link_tag.content.strip
        playerlinks.push([text, href])      
      end
    end

    counter = 0
    playerlinks.each do |playerlink|
      counter += 1
      text = playerlink[0]
      href = playerlink[1]

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

      # Get team abbr name
      career_avg_block_tr = player_doc.search('.careerAvg tr')
      current_team_row = 0
      if career_avg_block_tr.length == 2 # no data
        next
      elsif career_avg_block_tr.length == 3 # normal, single team in a season
        current_team_row = 1
      else # changed team
        current_team_row = career_avg_block_tr.length - 3
      end
      
      team_abbr = ''
      if first == 'Royce' and last = 'White' # Special case
        team_abbr = 'HOU'
      else
        team_abbr = career_avg_block_tr[current_team_row].search('td')[1].content
      end

      team_city = @TEAMS[team_abbr][0]
      team_name = @TEAMS[team_abbr][1]

      p = Player.new(:first_name => first, :last_name => last, :number => number,
                     :position => position, :url => link, :team_city => team_city, :team_name => team_name)
      p.save!
      puts first + " " + last + " finished. (" + counter.to_s + " of " + playerlinks.length.to_s + ")"

    end

  end
end