require 'bundler/setup'

require 'sinatra/base'
require 'rest-client'
require 'json'
require 'logger'

class SlackDockerApp < Sinatra::Base
  configure do
    if ENV['DEBUG']
      logger = ::Logger.new('/tmp/debug.log')
      use Rack::CommonLogger, logger
    else
      require './now_common_logger'
    end
  end

  get "/*" do
    params[:splat].first
  end

  # slack webhook
  post "/services/*" do
    docker = JSON.parse(request.body.read)
    logger.warn docker if ENV['DEBUG']

    #Docker Hub Data
    title_link = "<#{docker['repository']['repo_url']}|#{docker['repository']['repo_name']}>"

    #push data
    unixtime = "#{docker['push_data']['pushed_at']}"
    date = DateTime.strptime(unixtime, '%s')

    user = "#{docker['push_data']['pusher']}"

    slack = {
        "attachments" => [
            {
                "fallback" => "New image build: #{title_link} #{docker['push_data']['tag']}",
                "pretext" => "New image build: #{title_link} #{docker['push_data']['tag']}",
                "color" => "#170061",
                "fields" => [
                    {
                        "title" => "Notes",
                        "value" => "date: #{date}\nby: #{user}",
                        "short" => false
                    }
                ]
            }
        ]
    }

    begin
      RestClient.post("https://hooks.slack.com/services/#{params[:splat].first}", payload: slack.to_json) { |response, request, result, &block|
        RestClient.post(docker['callback_url'], {state: response.code == 200 ? "success" : "error"}.to_json, :content_type => :json)
      }
    rescue => e
      logger.error e.inspect
    end
  end

  # typetalk postBot
  post "/typetalkv1/*/*" do
    docker = JSON.parse(request.body.read)
    title_link = "[#{docker['repository']['repo_name']}](#{docker['repository']['repo_url']})"
    message = "New image build: #{title_link} #{docker['push_data']['tag']}"

    topic = params[:splat].first
    token = params[:splat].last
    begin
      RestClient.post(
        "https://typetalk.com/api/v1/topics/#{topic}",
        {typetalkToken: token, message: message}
      ) { |response, request, result, &block|
        RestClient.post(docker['callback_url'], {state: response.code == 200 ? "success" : "error"}.to_json, :content_type => :json)
      }
    rescue => e
      logger.error e.inspect
    end
  end
end

run SlackDockerApp
