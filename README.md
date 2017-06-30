# candy_check with oath for play_store

[![Gem Version](https://badge.fury.io/rb/candy_check.svg)](http://badge.fury.io/rb/candy_check)
[![Build Status](https://travis-ci.org/jnbt/candy_check.svg?branch=master)](https://travis-ci.org/jnbt/candy_check)
[![Coverage Status](https://coveralls.io/repos/jnbt/candy_check/badge.svg?branch=master)](https://coveralls.io/r/jnbt/candy_check?branch=master)
[![Code Climate](https://codeclimate.com/github/jnbt/candy_check/badges/gpa.svg)](https://codeclimate.com/github/jnbt/candy_check)
[![Gemnasium](https://img.shields.io/gemnasium/jnbt/candy_check.svg?style=flat)](https://gemnasium.com/jnbt/candy_check)
[![Inline docs](http://inch-ci.org/github/jnbt/candy_check.svg?branch=master)](http://inch-ci.org/github/jnbt/candy_check)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg?style=flat)](http://www.rubydoc.info/github/jnbt/candy_check/master)

Check and verify in-app receipts from the AppStore and the PlayStore.

## Installation

```Bash
gem install candy_check
```

## Introduction

This gem tries to simplify the process of server-side in-app purchase and subscription validation for Apple's AppStore and Google's PlayStore.

### AppStore

If you have set up an iOS app and its in-app items correctly and the in-app store is working your app should receive a
`SKPaymentTransaction`. Currently this gem assumes that you use the old [`transactionReceipt`](https://developer.apple.com/library/ios/documentation/StoreKit/Reference/SKPaymentTransaction_Class/index.html#//apple_ref/occ/instp/SKPaymentTransaction/transactionReceipt)
which is returned per transaction. The `transactionReceipt` is a base64 encoded binary blob which you should send to your
server for the validation process.

To validate a receipt one normally has to choose between the two different endpoints "production" and "sandbox" which are provided from
[Apple](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1).
During development your app gets receipts from the sandbox while when released from the production system. A special case is the
review process because the review team uses the release version of your app but processes payment against the sandbox.
Only for receipts that contain auto-renewable subscriptions you need your app's shared secret (a hexadecimal string),

Please keep in mind that you have to use test user account from the iTunes connect portal to test in-app purchases during
your app's development.

### PlayStore

This document outlines setting up google's ruby gem, google-api-client, to verify payloads(receipts) sent to a server from google play in app purchases made via an android app.  
This document was written using version 0.9.13.

First you'll need 'owner' access to the google play developer's console that contains the mobile app you wish to verify receipts from.  
* Go to https://play.google.com/apps/publish
* Click on the mobile app you'd like to set up
* Click "Settings" on the left click "API access"
* Below "LINKED PROJECT" link the google play account

Next setup an api account
* Go to http://console.developers.google.com
* From the left menu select "Credentials"
* From the center click "Create credentials"
* From the drop down select "OAuth client ID"
* From the "Application Type" list select "Web Application"
* Note your the "client id" and "client secret"

Now manually "login" with your oauth information (this video outlines the steps below  https://www.youtube.com/watch?v=hfWe1gPCnzc)
* go to https://developers.google.com/oauthplayground/
* Click the "cog" icon on the righ
* Check "User your own OAuth credentials"
* Select "Access Type" of "Offline"
* Enter the client id and client secret created from the previos step
* Under scopes on the left select "Google Play Developer API v2" and then 
* click "Authorize APIs'
* click "Allow'
* click "Exchange authorization code for tokens'
* note the "refresh token" and "access token"


## Usage

### AppStore

First you should initialize a verifier instance for your application:

```ruby
config = CandyCheck::AppStore::Config.new(
  environment: :production # or :sandbox
)
verifier = CandyCheck::AppStore::Verifier.new(config)
```

For the AppStore the client should deliver a base64 encoded receipt data string
which can be verified by using the following call:

```ruby
verifier.verify(your_receipt_data) # => Receipt or VerificationFailure
# or by using a shared secret for subscriptions
verifier.verify(your_receipt_data, your_secret)
```

Please see the class documenations [`CandyCheck::AppStore::Receipt`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/AppStore/Receipt) and [`CandyCheck::AppStore::VerificationFailure`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/AppStore/VerificationFailure) for further details about the responses.

For **subscription verification**, Apple also returns a list of the user's purchases. Essentially, this is a collection of receipts. To verify a subscription, do the following:

```ruby
# ... create your verifier as above
verifier.verify_subscription(your_receipt_data, your_secret) # => ReceiptCollection or VerificationFailure
```

Please see the class documentation for [`CandyCheck::AppStore::ReceiptCollection`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/AppStore/ReceiptCollection) for further details.

### PlayStore

```ruby
    verifier = CandyCheck::PlayStore::Auth.new(
      client_id: ENV['GOOGLE_OAUTH_CLIENT_ID'],
      client_secret: ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
      refresh_token: ENV['GOOGLE_OAUTH_CLIENT_TOKEN'],
      access_token: ENV['GOOGLE_OAUTH_ACCESS_TOKEN']
    )
    verifier.verify!(package_name, product_id, purchase_token)
```

For the PlayStore your client should deliver the purchases token, package name and product id:

```ruby
verifier.verify!(package_name, product_id, purchase_token) # => true or false
```



## Todos
* better test and documentation for play_store
* Allow using the combined StoreKit receipt data
* Find a ways to run integration tests

## Bugs and Issues

Please submit them here https://github.com/jnbt/candy_check/issues

## Test

Simple run

```Bash
rake
```

## Copyright

Copyright &copy; 2016 Jonas Thiel. See LICENSE.txt for details.
