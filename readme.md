# LBRY Slack Tipbot

## Requirements

- running instance of `lbrycrd` with RPC enabled
- web access to tipbot's port from Slack



## Setup

* `git clone https://github.com/lbryio/lbry-tipbot.git`
* Install Ruby 2.1.2 and rvm
  * `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
  * `gem install bundler`
  * To start using RVM you need to run `source /usr/local/rvm/scripts/rvm`
* `bundle`

### Set up the Slack integration: as a slash command

* https://lbry.slack.com/apps/new/A0F82E8CA-slash-commands
* Set the name of the command. We use `/tipbot`
* Write down the api token they show you in this page
* Set the url to `http://example.com:4567/tip`

### Launch the server!

* `RPC_USER=lbryrpc RPC_PASSWORD=your_pass SLACK_API_TOKEN=your_api_key bundle exec ruby tipper.rb -p 4567`



## Commands

* Help - see this help in Slack

  `/tipbot help`

* Tip - send someone coins

  `/tipbot tip @somebody 100`

* Deposit - put coin in

  `/tipbot deposit`

* Withdraw - take coin out

  `/tipbot withdraw LKzHM7rUB2sP1dgVskVFfdSoysnojuw2pX 100`

* Balance - find out how much is in your wallet

  `/tipbot balance`

* Networkinfo - Get the output of getinfo.  Note:  this will disclose the entire aggregate balance of the hot wallet to everyone in the chat

  `/tipbot networkinfo`



## Security

This runs an unencrypted hot wallet on your server. You should not store significant amounts of cryptocoins in this wallet. Withdraw your tips to an offline wallet often.

## Credits

This project was forked from [slack_tipbot](https://github.com/blocktech/slack_tipbot).
