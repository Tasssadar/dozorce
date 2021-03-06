require 'cgi'
require_relative '../utils/webpage'


class Csfd
  include Cinch::Plugin

  set :help, 'csfd [query] - returns info about queried movie. Example: csfd star wars xxx a porn parody'

  match /csfd (.+)/

  def execute(m, query)
    m.reply( search(query), true)
  end

  def search(query)
    search_url = "http://csfd.matousskala.cz/api/hledat.php?q=#{CGI.escape(query)}"
    search_result = WebPage.load_xml(search_url)
    search_ids = search_result.xpath("//film//id").first
    raise "No result" if search_ids.nil?

    movie_id = search_ids.content
    movie_url = "http://csfd.matousskala.cz/api/film.php?id=#{movie_id}"
    movie_result = WebPage.load_xml(movie_url)

    movie_title = movie_result.xpath("//nazev").first.content
    made_data = movie_result.xpath("//zeme").first.content
    parsed_made_data = made_data.match(/^(.[^,]*), ([0-9]{4}), (?:.[^0-9])*([0-9]{1,3} min)/)
    movie_country = parsed_made_data[1]
    movie_year = parsed_made_data[2]
    movie_length = parsed_made_data[3]
    movie_rating = movie_result.xpath("//rating").first.content
    movie_link = "http://www.csfd.cz/film/#{movie_id}"
    "#{movie_title} (#{movie_year}), #{movie_country}, #{movie_length}, #{movie_rating}% - #{movie_link}"
  rescue
    "No result"
  end
end
