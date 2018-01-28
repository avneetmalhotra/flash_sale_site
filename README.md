# README

## To use rails app - Flash Sale Site

### System Requirements
  - Ruby v2.4.0
  - Rails v5.1.4
  - DBMS - mysql  Ver 14.14 Distrib 5.6.28

### Setup
  - Install all gems
    ```sh
    $ bundle install
    ```
  - Initalize the app/config/database.yml file
  - Create the database
    ```sh
    $ rails db:create
    ```
  - Run all migrations
    ```sh
    $ rails db:migrate
    ```
  - Initalize app/config/secrets.yml, app/config/application.yml

### How to use
  - To create admin account, run
    ```sh
    $ rake admin:new
    ```
  - To create deals and manage the application, you need to login using your admin account.
  - Create non-admin user by going to Create Account page and then confirm your account to login using it.
  - To publish the current day's deals for 24 hours, run
    ```sh
    $ rake admin:publish_deal
    ```
