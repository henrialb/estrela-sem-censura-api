# frozen_string_literal: true

class FacebookService
  BASE_URL = "https://graph.facebook.com/v18.0"

  def initialize(access_token)
    @access_token = access_token
    @connection = Faraday.new(url: BASE_URL)
  end

  def fetch_page_posts(page_id, limit = 25)
    response = @connection.get("#{page_id}/posts") do |req|
      req.params["fields"] = "id,permalink_url,created_time"
      req.params["limit"] = limit
      req.params["access_token"] = @access_token
    end

    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error "Facebook API Error: #{response.status} - #{response.body}"
      raise "Facebook API request failed: #{response.body}"
    end
  end
end
