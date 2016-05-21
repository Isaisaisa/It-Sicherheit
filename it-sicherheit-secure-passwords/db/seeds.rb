# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name:  "Test User",
             email: "test@user.de",
             password:              "test123",
             password_confirmation: "test123")

User.create!(name:  "Test User2",
             email: "test2@user.de",
             password:              "test1234",
             password_confirmation: "test1234")

User.create!(name:  "Torben",
             email: "torben@user.de",
             password:              "test112",
             password_confirmation: "test112",
             admin: true)

User.create!(name:  "Louisa",
             email: "louisa@user.de",
             password:              "test122",
             password_confirmation: "test122",
             admin: true)