_ = require 'underscore'
Set = require 'collections/set'
async = require 'async'
concatstream = require 'concat-stream'
podcastgen = require 'podcastgen'

scrape = require '../scraper'

module.exports = (app, db) ->
  routes =
    shows: (req, res) ->
      shows = new Set()

      db.createReadStream().pipe concatstream (podcastRecords) ->
        return res.json [] unless podcastRecords and podcastRecords.length

        _.each _.pluck(podcastRecords, 'value'), (podcast) ->
          shows.add podcast.show if podcast.show

        res.json shows.toArray()

    builder: (req, res) -> res.render 'shows'

    podcast: (req, res) ->
      db.createReadStream().pipe concat (podcastRecords) ->
        if podcastRecords and podcastRecords.length
          podcasts = _.pluck podcastRecords, 'value'
          
          if req.query.shows
            shows = new Set(req.query.shows.split(','))
            podcastsFiltered = _.filter podcasts, (podcast) -> shows.has podcast.show
          else
            podcastsFiltered = podcasts

          # res.render 'podcasts', {podcasts}
          res.send podcastgen
            title: "rinse fm podcast"
            baseUrl: ""
            podcastUrl: "http://localhost:3000/"
            items: _.map podcastsFiltered, (podcast) ->
              title: podcast.title
              path: podcast.file
              date: podcast.airdate
        else
          res.send 'out of clay'

    update: (req, res) ->
      page = req.query.page || 1
      url = "http://rinse.fm/podcasts/?page=#{page}"

      persist = (podcast, done) ->
        db.put podcast.file, podcast, done

      scrape url, (podcasts) ->
        async.each podcasts, persist, (err) ->
          console.error err if err
          res.json podcasts
  
  routes