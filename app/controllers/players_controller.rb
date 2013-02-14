class PlayersController < ApplicationController
  def show
    @player = Player.find_by_id(params[:id])
  end

  def search
    # Get param "query", parse query into tokens, and find relevant players
    players = nil
    query = params[:query]
    if query != nil
      # parse query
      query_terms = query.strip.split(/\s+/)

      # construct full query string
      query_string = ''
      query_terms.each do |term|
        query_string += ('first_name_text:'+ term +'~0.5 OR ')
        query_string += ('last_name_text:'+ term +'~0.5 OR ')
      end
      query_string = query_string[0..-4] # cut last ' OR '
      puts query_string
      
      players = Player.search do
        adjust_solr_params do |params|
          params[:q] = query_string;
          params[:defType] = 'lucene'
        end
      end.results
    end
    
    render :json => players
    # respond_to do |format|
    #   format.html { render :action => "index" }
    #   format.xml  { render :xml => @books }
    # end
  end

  def search_page
  end
end
