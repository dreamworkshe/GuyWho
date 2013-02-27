require 'nokogiri'
require 'open-uri'

class PlayersController < ApplicationController
  include PlayersHelper

  def show
    @player = Player.find_by_id(params[:id])
  end

  # render json given a query
  def search
    # Get param "query", parse query into tokens, and find relevant players
    players = nil
    query = params[:query]
    
    if query != nil
      # TODO: downcase
      # parse query
      query_terms = query.downcase.strip.split(/\s+/)

      # construct full query string
      query_string = ''
      query_terms.each do |term|
        if term[0] == '#'
          term = term[1..-1]
        end
        query_string += ('first_name_text:'+ term +'~0.5 OR ')
        query_string += ('last_name_text:'+ term +'~0.5 OR ')
        query_string += ('team_name_text:'+ term +'~0.5 OR ')
        query_string += ('team_city_text:'+ term +'~0.5 OR ')
        query_string += ('number_text:'+ term +'~0.5 OR ')
      end
      query_string = query_string[0..-4] # cut last ' OR '
      
      # assign query string and get results
      players = Player.search do
        adjust_solr_params do |params|
          params[:q] = query_string;
          params[:defType] = 'lucene'
        end
      end.results
    end
    
    render :json => players
  end

  def search_page
  end

  def get_info
    id = params[:id]
    player = Player.find_by_id(id)
    # Handle wrong id
    if id == nil or player == nil
      render :text => 'Not Found', :status => 503
    end

    # Found player
    doc = Nokogiri::HTML(open(player.url))
    stats = doc.css('dl#prastats dd')
    ppg = stats[0].text.strip()
    rpg = stats[1].text.strip()
    apg = stats[2].text.strip()
    name_url = ''
    if player.url =~ /http:\/\/www.nba.com\/playerfile\/(.+)\//
      name_url = $1
    end
    imgurl = 'http://i.cdn.turner.com/nba/nba/media/act_'+name_url+'.jpg'

    # Get news
    news = getNews("#{player.first_name} #{player.last_name}")

    info = {:ppg => ppg, :rpg => rpg, :apg => apg, :img => imgurl, :news => news}

    render :json => info
  end


end
