require 'bundler/setup'

require 'sinatra/base'
require 'rest-client'
require 'json'
require 'logger'

class SlackDockerApp < Sinatra::Base
  logger = ::Logger.new($stdout)
  get "/*" do
    params[:splat].first
  end
  post "/*" do
    docker = JSON.parse(request.body.read)

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
      RestClient.post("https://hooks.slack.com/#{params[:splat].first}", payload: slack.to_json) { |response, request, result, &block|
        RestClient.post(docker['callback_url'], {state: response.code == 200 ? "success" : "error"}.to_json, :content_type => :json)
      }
    rescue => e
      logger.error e.inspect
    end
  end
end

run SlackDockerApp
