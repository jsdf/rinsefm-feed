_ = require 'underscore'
Set = require 'collections/set'
async = require 'async'
concat = require 'concat-stream'
scrape = require '../scraper'
podcastgen = require 'podcastgen'

module.exports = (app, db) ->
  routes =
    list: (req, res) ->
      shows = new Set()
      db.createReadStream().pipe concat (podcastRecords) ->
        if podcastRecords and podcastRecords.length
          podcasts = _.pluck podcastRecords, 'value'
          _.each podcasts, (podcast) ->
            shows.add podcast.show if podcast.show

          res.render 'shows', {shows: shows.toArray()}

    podcast: (req, res) ->
      db.createReadStream().pipe concat (podcastRecords) ->
        if podcastRecords and podcastRecords.length
          podcasts = _.pluck podcastRecords, 'value'
          
          if req.query.shows
            shows = new Set(_.keys req.query.shows)
            podcastsFiltered = _.filter podcasts, (podcast) -> shows.has podcast.show
          else
            podcastsFiltered = podcasts

          # res.render 'podcasts', {podcasts}
          res.send podcastgen {
            title: "rinse fm podcast",
            baseUrl: "",
            podcastUrl: "http://localhost:3000/",
            items: _.map podcastsFiltered, (podcast) ->
              title: podcast.title,
              path: podcast.file,
              date: podcast.airdate,
          }
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