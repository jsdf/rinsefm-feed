request = require 'request'
cheerio = require 'cheerio'

fetch = (url, next) ->
  request url, (error, response, body) ->
    if error then console.error error
    else if response.statusCode is not 200 then console.log response.statusCode, response
    else next body

parse = (body, next) ->
  showUrlPattern = /\/artists\/(.+)\//
  $ = cheerio.load body

  podcasts = $('#podcasts-listing .podcast-list-item').map (index, element) ->
    $el = $(element)

    title: $el.find('h3').text().trim()
    file: $el.find('.download a').attr('href') || $el.find('.listen a').attr('href')
    airtime: $el.attr('data-airtime')
    airdate: $el.attr('data-air_day')
    show: do ->
      showUrl = $el.find('h3 a').attr('href')
      matches = showUrlPattern.exec(showUrl)
      if matches? then matches[1] else null

  next podcasts

scrape = (url, done) ->
  fetch url, (body) ->
    parse body, done

module.exports = scrape
