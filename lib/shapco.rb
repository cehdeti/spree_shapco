class StackExchange
  include HTTParty
  base_uri 'http://www.shapcoinsight.com/API'

  def initialize(prefix)
    @prefix = prefix
    @token = nil
  end

  def login(username, password, subscriber_id)
    @token = self.class.get('/api/login', query: {
      'UserName' => username,
      'Password' => password,
      'SubscriberId' => subscriber_id
    })
  end

  def create_order(order)
    self.class.post("/#{@prefix}/postorder", params: order)
  end
end
