# TODO: adapt to use promises
request = require 'request'
cheerio = require 'cheerio'

# the part of the scraper which does the actual work
# in a mostly functional style
scraper =
  get: (url, callback) ->
    request url, (error, response, body) =>
      if error then console.error error
      else if response.statusCode is not 200 then console.log response.statusCode, response
      else callback body

  parse: (body, callback) ->
    showUrlPattern = /\/artists\/(.+)\//
    $ = cheerio.load body

    podcasts = $('#podcasts-listing .podcast-list-item').map (index, element) ->
      $el = $(element)

      title: $el.find('h3').text().trim()
      file: $el.find('.listen a').attr('href')
      airtime: $el.attr('data-airtime')
      airdate: $el.attr('data-air_day')
      show: do ->
        showUrl = $el.find('h3 a').attr('href')
        matches = showUrlPattern.exec(showUrl)
        if matches? then matches[1] else null

    callback podcasts

  write: (podcasts) ->
    console.log podcasts

  scrape: (url) ->
    @get(url, (body) =>
      @parse(body, (podcasts) =>
        @write podcasts))

module.exports = scraper