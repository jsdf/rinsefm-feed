db = require './db'

# url = 'http://rinse.fm/podcasts/'
url = 'http://localhost:3000/rinse/podcasts.html' # testing url

require('./scraper').scrape(url)
