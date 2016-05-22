# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name:  "Test User",
             email: "test@user.de",
             password:              "T3$t1234",
             password_confirmation: "T3$t1234",
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "Test User2",
             email: "test2@user.de",
             password:              "T3$t1234",
             password_confirmation: "T3$t1234",
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "Torben",
             email: "torben@user.de",
             password:              "T3$t1234",
             password_confirmation: "T3$t1234",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "Louisa",
             email: "louisa@user.de",
             password:              "T3$t1234",
             password_confirmation: "T3$t1234",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)