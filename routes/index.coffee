_ = require 'underscore'
Set = require 'collections/set'
async = require 'async'
concatstream = require 'concat-stream'
moment = require 'moment'
podcastgen = require 'podcastgen'

scrape = require '../scraper'

moment.lang 'en'
DATE_RFC2822 = "ddd, DD MMM YYYY HH:mm:ss ZZ"

cache = (res, maxAge) ->
  res.set "Cache-Control":"public, max-age=#{maxAge}"

requestUrl = (req) ->
  "#{req.protocol}://#{req.get('host')}#{req.originalUrl}"

module.exports = (app, db, config) ->
  authorised = (req) ->
    config.secret and req.query.secret is config.secret

  loadPodcasts = (done) ->
    db.createReadStream().pipe concatstream (podcastRecords) ->
      if podcastRecords and podcastRecords.length
        done _.pluck(podcastRecords, 'value')
      else
        done []

  showsFromPodcasts = (podcasts) ->
    _.reduce(podcasts, (shows, podcast) ->
      shows.add podcast.show if podcast.show
      shows
    , new Set())

  # routes
  shows: (req, res) ->
    cache res, config.maxAgeDynamic

    loadPodcasts (podcasts) ->
      res.json showsFromPodcasts(podcasts).sorted()

  builder: (req, res) ->    
    cache res, config.maxAgeDynamic
  
    loadPodcasts (podcasts) ->
      showsSorted = showsFromPodcasts(podcasts).sorted()

      res.render 'shows', {showsJSON: -> JSON.stringify(showsSorted)}

  podcast: (req, res) ->
    cache res, config.maxAgeDynamic

    loadPodcasts (podcasts) ->
      if req.query.shows
        shows = new Set(req.query.shows.split(','))
        podcastsFiltered = _.filter podcasts, (podcast) -> shows.has podcast.show
      else
        podcastsFiltered = podcasts

      if shows
        title = "rinse fm shows: #{shows.sorted().join(', ')}"
      else
        title = "rinse fm podcast"

      sortByTimeDesc = (items) -> _.sortBy(items, (item) -> -item.timestamp)

      res.send podcastgen
        title: title
        baseUrl: ""
        podcastUrl: requestUrl(req)
        items: sortByTimeDesc _.map podcastsFiltered, (podcast) ->
          dateParsed = new Date(podcast.airdate)

          title: podcast.title
          path: podcast.file
          date: moment(dateParsed).format(DATE_RFC2822)
          timestamp: dateParsed.getTime()

  list: (req, res) ->
    return res.send 403 unless authorised req

    loadPodcasts (podcasts) ->
      res.write JSON.stringify(process.env, null, 2)+"\n"

      _.each(
        _.sortBy(podcasts, (podcast) -> - new Date(podcast.airdate).getTime())
      , (podcast) -> res.write "#{podcast.airdate} #{podcast.title} [#{podcast.show}]\n")

      res.end()

  update: (req, res) ->
    return res.send 403 unless authorised req

    page = req.query.page or 1
    url = "http://rinse.fm/podcasts/?page=#{page}"

    persistPodcast = (podcast, done) -> db.put(podcast.file, podcast, done)

    scrape url, (podcasts) ->
      async.each podcasts, persistPodcast, (err) ->
        console.error err if err
        res.json podcasts
