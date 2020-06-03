Dotenv.load
RSpec.describe Zerodha do
  it "has a version number" do
    expect(Zerodha::VERSION).not_to be nil
  end

  context "without access token" do

    describe Zerodha::Client do
      let(:c) { Zerodha::Client.new(api_key: ENV["ZERODHA_API_KEY"], api_secret: ENV["ZERODHA_API_SECRET"], request_token: ENV["ZERODHA_REQUEST_TOKEN"]) }
      it "should fetch the access_token", :logged_out => true do
        ap c.access_token
        expect(c.access_token).to_not be(nil)
      end
    end
  end

  context "with access_token", :logged_in => true  do
    let(:c) { Zerodha::Client.new(api_key: ENV["ZERODHA_API_KEY"],access_token: ENV["ZERODHA_ACCESS_TOKEN"]) }
    it "should fetch some data" do
        r = c.get("/user/margins")
        expect(r.success?).to be(true)
    end
    it "should fetch instruments", :skip => true do
      r = c.instruments
    end

    it "should fetch historical data" do
      r = c.historical(12517890,"10minute","2019-12-17 09:30:00","2019-12-17 10:30:00")
      ap r.parsed_response
      expect(r.success?).to be(true)
    end
    it "should get a quote" do
      r = c.get("/quote/?i=NSE:INFY")
      expect(r.success?).to be(true)
    end
  end
end
