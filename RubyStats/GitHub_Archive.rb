module RubyStats
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'openssl'
require 'yaml'

class GitHub_Archive

  @client
  @bigQuery
  @project_id = "135478500051"

  def initialize

    app_config = YAML.load_file("config.yml")

    @project_id = app_config['Google']['projectId']
    secret = app_config['Google']['client']['secret']

    @client = Google::APIClient.new(:application_name    => 'RubyStats',
                                    :application_version => '0.0.1' )

    #TODO: flush out / finish this service account example
    key = Google::APIClient::KeyUtils.load_from_pkcs12('client.p12', secret)
    @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience             => 'https://accounts.google.com/o/oauth2/token',
        :scope                => 'https://www.googleapis.com/auth/bigquery.readonly',
        :issuer               => '135478500051-hgniagsduomdoqi1k1ruqrkbfhbuitkk@developer.gserviceaccount.com',
        :signing_key          => key)
    @client.authorization.fetch_access_token!

    # Initialize BigQuery API. Note this will make a request to the
    # discovery service every time, so be sure to use serialization
    # in your production code. Check the samples for more details.
    @bigQuery = @client.discovered_api('bigquery', 'v2')

    #doc = File.read('bigQueryAPI.json')
    #@bigQuery = @client.register_discovery_document('bigquery', 'v2', doc)

  end

  def get_averages
    initialize
    begin
      result = @client.execute!(
                 #:api_method =>  @bigQuery.query,
                 #:api_method =>  @bigQuery.queries,
                 #:api_method =>  @bigQuery.Jobs.query,
                 #:api_method => "queries", #@bigQuery.batch_path.query,
                 #:api_method => @bigQuery.jobs.query,
                 #:api_method => @bigQuery.resources.jobs.query,
                 #:api_method => @bigQuery.Resources.jobs.query,
                 #:api_method => @bigQuery.Jobs.query,
                 :api_method => @bigQuery.jobs.query,
                 :body_object => { "query" => "SELECT count(DISTINCT repository_name) as repository_total, " +
                                       "count(payload_commit) as commits_total, " +
                                       "count(DISTINCT repository_name) / count(payload_commit) as average, " +
                                       "FROM [githubarchive:github.timeline]" }, #,
                            #"defaultDataset" => { "datasetId" => "GHAverages" }},
                 :parameters => { "projectId" => @project_id })
                 #:parameters => { "projects" => @project_id })
    #rescue NoMethodError => nme
    rescue Google::APIClient::ClientError => nme
      #puts 'Error getting averagees: ' + nme.message
      #puts 'dir_uri: ' + (nil != @client.directory_uri ? @client.directory_uri : 'NIL')
      puts '----------- BEGIN CLIENT INSPECTION --------------'
      puts @client.inspect
      puts '----------- BEGIN Big Query INSPECTION --------------'
      #puts @bigQuery.inspect
      #puts '----- LIST PUBLIC METHODS --------'
      #puts @bigQuery.public_methods
      puts '----- LIST Instance variables ----'
      #puts @bigQuery.pretty_print_instance_variables
      puts '-----  '
      #puts @bigQuery.pretty_print_inspect
      #p @bigQuery
      puts '#------#'
      puts @bigQuery.pretty_inspect
      puts '-----  '

      #puts 'methods: ' + (nil != @bigQuery.discovered_methods ?
      #     '[' + @bigQuery.discovered_methods.join(',') + ']' : 'NIL')
      #puts 'Base: ' + (nil != @bigQuery.method_base ?
      #                        @bigQuery.method_base : 'NIL')
      puts '----------- END of INSPECTION --------------'
      raise nme
    end

    return result
  end

  def get_language_stats
    @bigQuery.jobs.query
    result = @client.execute(
               #:api_method => @bigQuery.Jobs.query,
               #:api_method => @bigQuery.batch_path.query,
               #:api_method => @bigQuery.batch_path.query,
               :api_method => @bigQuery.jobs.query,
               :body_object => { "query" => "SELECT repository_language, " +
                                            "count(DISTINCT repository_name) as repository," +
                                            "count(payload_commit) as commits" +
                                            "count(DISTINCT repository_name) / count(payload_commit) as ratio" +
                                            "FROM [githubarchive:github.timeline]" +
                                            "GROUP BY repository_language" +
                                            "ORDER BY repository_language LIMIT 1000",
                                            "defaultDataset" => { "datasetId" => "GHStats" }},
               :parameters => { "projectId" => @project_id })

    return result
  end

  #perform both queries at once in a "batch"
  def get_ratios
    batch = Google::APIClient::BatchRequest.new do |result|
      #puts result.data
      return result
    end

    #averages
    batch.add(#:api_method => @bigQuery.Jobs.query,
              :api_method => @bigQuery.batch_path.query,
              :body_object => { "query" => "SELECT count(DISTINCT repository_name) as repository_total, " +
                                           "count(payload_commit) as commits_total, " +
                                           "count(DISTINCT repository_name) / count(payload_commit) as average, " +
                                           "FROM [githubarchive:github.timeline]",
                                "defaultDataset" => { "datasetId" => "GHAverages" }},
              :parameters => { "projectId" => @project_id })

    batch.add(#:api_method => @bigQuery.Jobs.query,
              :api_method => @bigQuery.batch_path.query,
              :body_object => { "query" => "SELECT repository_language, " +
                                           "count(DISTINCT repository_name) as repository," +
                                           "count(payload_commit) as commits" +
                                           "count(DISTINCT repository_name) / count(payload_commit) as ratio" +
                                           "FROM [githubarchive:github.timeline]" +
                                           "GROUP BY repository_language" +
                                           "ORDER BY repository_language LIMIT 1000",
                                "defaultDataset" => { "datasetId" => "GHStats" }},
              :parameters => { "projectId" => @project_id })

    return @client.execute(batch)
  end

end
end