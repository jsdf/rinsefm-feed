config = require './config.json'
Sequelize = require 'sequelize'

db = new Sequelize(config.db.database, config.db.username, config.db.password)

db.Podcast: db.define 'Podcast',
    artist: Sequelize.STRING
    file: type: Sequelize.STRING, primaryKey: true
    show: Sequelize.STRING
    date: Sequelize.DATE
    # classMethods:
    #   write:

module.exports = db