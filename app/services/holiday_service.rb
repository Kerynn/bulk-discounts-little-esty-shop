# require 'httparty'
# require 'json'

# class HolidayService 

#   def next_holidays 
#     get_url("https://date.nager.at/api/v3/PublicHolidays/2023/us")
#   end

#   def get_url(url)
#     response = HTTParty.get(url)
#     parsed = JSON.parse(response.body, symbolize_names: true)
#   end
# end