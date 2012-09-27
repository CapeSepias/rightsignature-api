require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::OauthConnection do
  before do
    @consumer_mock = mock(OAuth::Consumer)
    @access_token_mock = mock(OAuth::AccessToken)
  end

  describe "oauth_consumer" do
    after do
      # Reset caching of oauth_consumer
      RightSignature::OauthConnection.instance_variable_set("@oauth_consumer", nil)
    end

    it "should raise error if no configuration is set" do
      RightSignature.should_receive(:has_oauth_credentials?).and_return(false)
      lambda{RightSignature::OauthConnection.oauth_consumer}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end
    
    it "should return consumer if configuration set" do
      RightSignature.should_receive(:has_oauth_credentials?).and_return(true)
      OAuth::Consumer.should_receive(:new).with(
        "Consumer123",
        "Secret098",
        {
         :site              => "https://rightsignature.com",
         :scheme            => :header,
         :http_method        => :post,
         :authorize_path    =>'/oauth/authorize', 
         :access_token_path =>'/oauth/access_token', 
         :request_token_path=>'/oauth/request_token'
        }).and_return(@consumer_mock)
      RightSignature::OauthConnection.oauth_consumer.should == @consumer_mock
    end
  end

  describe "access_token" do
    after do
      # Reset caching of oauth_consumer
      RightSignature::OauthConnection.instance_variable_set("@access_token", nil)
    end
    
    it "should raise error if no configuration is set" do
      RightSignature.should_receive(:has_oauth_credentials?).and_return(false)
      lambda{RightSignature::OauthConnection.access_token}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end
    
    it "should create OAuth access token with credentials" do
      OAuth::Consumer.should_receive(:new).and_return(@consumer_mock)
      OAuth::AccessToken.should_receive(:new).with(@consumer_mock, 'AccessToken098', 'AccessSecret123')

      RightSignature::OauthConnection.access_token
    end
  end

  describe "request" do
    it "should raise error if no configuration is set" do
      RightSignature.should_receive(:has_oauth_credentials?).and_return(false)
      lambda{RightSignature::OauthConnection.request(:get, "path", {"User-Agent" => 'My own'})}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end
    
    it "should create GET request with access token and path with custom headers as 3rd argument" do
      @access_token_mock.should_receive(:get).with('path', {"User-Agent" => 'My own', "Accept"=>"*/*", "content-type"=>"application/xml"})
      RightSignature::OauthConnection.stub(:access_token).and_return(@access_token_mock)
      RightSignature::OauthConnection.request(:get, "path", {"User-Agent" => 'My own'})
    end

    it "should create POST request with access token and path with body as 3rd argument and custom headers as 4th argument" do
      @access_token_mock.should_receive(:post).with('path', "<template></template>", {"User-Agent" => 'My own', "Accept"=>"*/*", "content-type"=>"application/xml"})
      RightSignature::OauthConnection.stub(:access_token).and_return(@access_token_mock)
      RightSignature::OauthConnection.request(:post, "path", "<template></template>", {"User-Agent" => 'My own'})
    end
  end

end