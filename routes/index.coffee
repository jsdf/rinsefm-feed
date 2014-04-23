_ = require 'underscore'
Set = require 'collections/set'
SortedSet = require 'collections/sorted-set'
async = require 'async'
concatstream = require 'concat-stream'
moment = require 'moment'
podcastgen = require 'podcastgen'

scrape = require '../scraper'

moment.lang 'en'
DATE_RFC2822 = "ddd, DD MMM YYYY HH:mm:ss ZZ"

module.exports = (app, db, config) ->
  authorised = (req, res) ->
    if config.secret and req.query.secret is config.secret
      true
    else
      res.send(403)
      false

  shows: (req, res) ->
    shows = new SortedSet()

    db.createReadStream().pipe concatstream (podcastRecords) ->
      return res.json [] unless podcastRecords and podcastRecords.length

      _.each _.pluck(podcastRecords, 'value'), (podcast) ->
        shows.add podcast.show if podcast.show

      res.json shows.toArray()

  builder: (req, res) -> res.render 'shows'

  podcast: (req, res) ->
    db.createReadStream().pipe concatstream (podcastRecords) ->
      if podcastRecords and podcastRecords.length
        podcasts = _.pluck podcastRecords, 'value'
        
        if req.query.shows
          shows = new Set(req.query.shows.split(','))
          podcastsFiltered = _.filter podcasts, (podcast) -> shows.has podcast.show
        else
          podcastsFiltered = podcasts

        if shows
          title = "rinse shows #{shows.toArray().join(', ')}"
        else
          title = "rinse fm podcast"

        sortByTimeDesc = (items) -> _.sortBy(items, (item) -> -item.timestamp)

        res.send podcastgen
          title: title
          baseUrl: ""
          podcastUrl: "http://localhost:3000/"
          items: sortByTimeDesc _.map podcastsFiltered, (podcast) ->
            dateParsed = new Date(podcast.airdate)

            title: podcast.title
            path: podcast.file
            date: moment(dateParsed).format(DATE_RFC2822)
            timestamp: dateParsed.getTime()
      else
        res.send 404, 'out of clay'

  list: (req, res) ->
    return unless authorised req, res

    db.createReadStream().pipe concatstream (podcastRecords) ->
      if podcastRecords and podcastRecords.length
        _.each(
          _.sortBy(
            _.pluck(podcastRecords, 'value')
          , (podcast) -> - new Date(podcast.airdate).getTime())
        , (podcast) -> res.write "#{podcast.airdate} #{podcast.title} [#{podcast.show}]\n")
        res.end()
      else
        res.send 404


  update: (req, res) ->
    return unless authorised req, res

    page = req.query.page or 1
    url = "http://rinse.fm/podcasts/?page=#{page}"

    persistPodcast = (podcast, done) -> db.put(podcast.file, podcast, done)

    scrape url, (podcasts) ->
      async.each podcasts, persistPodcast, (err) ->
        console.error err if err
        res.json podcasts
