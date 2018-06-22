
require 'faraday_middleware'
require 'nokogiri'

# The Zillow API call is broken down into a two parts:
# - The Zillow Web Service 
# 		"http://www.zillow.com/webservice/GetRegionChildren.htm"
# - An API key (be careful not to share)
reqUrl = 'http://www.zillow.com/webservice/GetSearchResults.htm'
zkey = "X1-ZWz18i7y9p2brf_6o78e"



# must add zws-id in url if not you get 301 response its required

# The Zillow API call is broken down into a two parts:
# - The Zillow Web Service
# 		"http://www.zillow.com/webservice/GetRegionChildren.htm"
# - An API key (be careful not to share)

apiKey = '?zws-id=' + zkey


urlWithKey = reqUrl +apiKey

# tried using xml in faraday request but got :xml is not registered on Faraday::Request
# The json request middleware was removed from Faraday in 0.8.
# It is now in the faraday_middleware gem. 
# You should gem install faraday_middleware and require it in the file that creates the Faraday object.
# adapter was required without it I got - No adapter was configured for this request


describe "Test api" do

	before(:all) do
		@connection = Faraday.new(:url => urlWithKey) do |faraday|
			faraday.request :json
			faraday.response :json, :content_type => /\bjson$/
			faraday.adapter Faraday.default_adapter 
		end
	end

# The parameters of this API are:
# zws-id REQUIRED -The Zillow Web Service Identifier.
# address REQUIRED	The address of the property to search. This string should be URL encoded.	Yes
# citystatezip REQUIRED	The city+state combination and/or ZIP code for which to search. This string should be URL encoded. Note that giving both city and state is required. Using just one will not work.	Yes
# rentzestimate	NOT REQUIRED Return Rent Zestimate information if available (boolean true/false, default: false)
	context 'sending params in request' do

		before(:all) do
			@response = @connection.get do |request|
				request.params['address'] = '1619 W. Beacon Ave'
				request.params['citystatezip'] = 'Anaheim, CA'
			end
		end

		# I noticed the api still responds with a 200 status code 
		# even if the response body has error therefore I must then parse through the xml body
		
		it 'responds with a 200 Success' do
			response = @response.status
			if @response.status != 200
				raise "wrong status code"
			else
				expect(@response.status).to eq 200
			end

		end

		# to verify the response I will need to parse through the xml body
		# to do this I used nokogiri and node methods of xpath and css

		it 'has the correct body response' do
			@doc = Nokogiri::XML(@response.body)

			# expect(@doc.xpath("//city")).text.to eq "ANAHEIM"
			city = @doc.xpath("//city").text
			state = @doc.xpath("//state").text
			address = @doc.xpath("//street").text

			puts city
			puts state
			puts address

			expect(city).to be == "ANAHEIM"
			expect(state).to be == "CA"
			expect(address).to be == "1619 W Beacon Ave"

		end

end
end
