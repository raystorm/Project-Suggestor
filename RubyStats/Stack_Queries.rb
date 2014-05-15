module RubyStats
#require serel
require 'Serel'

class Stack_Queries
  #Class running Stack Exchange Queries

  #def config(retriever)
  def config
    app_config = YAML.load_file("config.yml")
    apiKey = app_config['stackOverflow']['apiKey']

    Serel::Base.config(:stackoverflow, apiKey)
  end

  def check_tag(languages)
    initialize
    tags = []

    #TODO: send 100 names at a time
    #TODO: for( h = 0; h < language.length; h+=100) what is the equivalent?
    h = 0
    while h  < languages.length
      send_tags = languages[h, (h+100)]
      h+=100
      found = Serel::Tag.find_by_name(send_tags)
      if ( found && found.is_a?(Array) ) then tags.concat(found)
      else_if ( found && found.is_a?(Serel::Tag) )
        #TODO look up single element add to end
        arr = []
        arr[0] = found
        tags.concat(arr)
      end
    end
    return tags
  end

  def get_questions_count(language)
    initialize
    count = Serel::Question.search.filter(:total).tagged(language).get
    #retriever = Serel::Question.new
    #onfig(retriever)
    return count
  end

end
end