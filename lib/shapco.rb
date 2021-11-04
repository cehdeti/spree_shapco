require 'httparty'

class Shapco
  include HTTParty
  base_uri 'https://www.shapcoinsight.com/api'
  debug_output

  def initialize(url_slug, username, password, subscriber_id)
    @url_slug = url_slug
    @username = username
    @password = password
    @subscriber_id = subscriber_id
  end

  def create_order(order)
    response = self.class.post(
      "/#{@url_slug}/postorder",
      body: order.to_json,
      headers: { Authorization: "Bearer #{token}", 'Content-Type': 'application/json' }
    )
    JSON.parse(response.body)
  end

  private

  def token
    response = self.class.post(
      '/api/auth/login',
      body: { UserName: @username, Password: @password, SubscriberId: @subscriber_id }.to_json,
      headers: { 'Content-Type': 'application/json' }
    )
    JSON.parse(response.body)['token']
  end
end
