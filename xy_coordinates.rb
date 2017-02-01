require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
require 'rubygems'
require 'mechanize'
require 'csv'
require 'rinku'

# THIS CODE IS FOR TAKING THE LONGITUDE AND LATITUDE VALUES
# FROM THE CSV FILE AND CONVERTING THEM TO THE NORTHING AND
# EASTING COORDINATES (FOR GIS) USING THE BRITISH GEOLOGICAL
# SURVEY CONVERTER; THEN, TO SAVE THE RESULTS IN THE CSV FILE

# this is to define our url
url = 'http://www.bgs.ac.uk/data/webservices/convertForm.cfm#convertToBNG'

# this is to instantiate a new mechanize object
agent = Mechanize.new

# this is to fetch the webpage
page = agent.get(url)

# this is to print the page to see what html names are used for
# the form and fields
# pp page

# this is to fetch the form
search_form = page.form('convertToBNG')
# pp search_form

# this is to create an empty arrays to store the csv input values in
long_array = []
lat_array = []

# this is to read the values from the CSV file and
# put the longitude and latitude values in the above arrays
points_array = CSV.parse(File.read("points.csv"))

points_array.each do |row|
	long_array.push(row[2])
  	lat_array.push(row[3])
  end

# puts long_array
# puts lat_array

# this is to create empty arrays to store the outputs
coordinates_array_easting = []
coordinates_array_northing = []

# this is the value of the counter which equals to the number
# of csv long - lat pairs to convert: needed for the loop
counter = 38

# this is the initial value of i for the while loop
i = 1

# this is where the loop starts
while i < counter

	# this is to set the values of two fields of the form
	search_form['longitude'] = long_array[i]
	search_form['latitude'] = lat_array[i]

	# this is to submit the form
	page = agent.submit(search_form)
	#pp page

	# this is to scrap the results from the webpage
	easting = page.css('.rightCol50').css('p')[0].text
	easting = easting.gsub("Easting: ","")
	northing = page.css('.rightCol50').css('p')[1].text
	northing = northing.gsub("Northing: ","")

	# this is to push the scraped data into the result arrays
	coordinates_array_easting.push(easting)
	coordinates_array_northing.push(northing)

	#puts coordinates_array_easting
	#puts coordinates_array_northing

	i = i + 1

end

# this is to transpose the data in the arrays in order to get
# the same layout as in the columns of the csv file
table = [coordinates_array_easting, coordinates_array_northing].transpose

# this is to push the data in the csv file
CSV.open("points.csv", 'a+') do |csv|
	table.each do |row|
		csv << row
	end
end

