require 'bitcoin-client'
require './bitcoin_client_extensions.rb'

class Command
  attr_accessor :result, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance deposit tip withdraw networkinfo help)

  def initialize(slack_params)
    #raise "WACK" unless slack_params['command'] == '/tipbot'

    @command = slack_params['command']
    @params = slack_params['text'].split(/\s+/)
    @user_name = slack_params['user_name']
    @user_id = slack_params['user_name']
    @action = @params.shift
    @result = {}

    @currency='LBC'
    @tx_template = " (<https://explorer.lbry.io/tx/TXID|tx>)"
  end

  def perform
    if ACTIONS.include?(@action)
      self.send("#{@action}".to_sym)
    else
      raise "I don't know how to do that"
    end
  end

  def client
    @client ||= Bitcoin::Client.local
  end

  def balance
    balance = client.getbalance(@user_id)
    @result[:text] = "@#{@user_name} You have #{balance}#{@currency}"
  end

  def deposit
    @result[:text] = "Your address is #{user_address(@user_id)}"
  end

  def tip
    target_user = @params.shift
    puts target_user
    raise "proper syntax is `tip @username AMOUNT`" unless target_user =~ /@(.+)/

    target_user = target_user.sub('@','')
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result[:text] = "Wubba lubba dub dub! @#{@user_id} tipped @#{target_user} #{@amount}#{@currency}"
    @result[:text] += @tx_template.sub('TXID', tx)
    @result[:response_type] = 'in_channel'
  end

  def withdraw
    address = @params.shift
    raise "proper syntax is `withdraw ADDRESS AMOUNT`" unless address

    set_amount

    tx = client.sendfrom @user_id, address, @amount
    @result[:text] = "@#{@user_id} withdrew #{@amount}#{@currency} to #{address}"
    @result[:text] += @tx_template.sub('TXID', tx)
    @result[:icon_emoji] = ":shit:"
  end

  def networkinfo
    info = client.getinfo
    @result[:text] = info.to_s
    @result[:icon_emoji] = ":bar_chart:"
  end

  private

  def set_amount
    amount = @params.shift
    @amount = amount.to_i
    randomize_amount if (@amount == "random")

    min_amount = 0.00000001

    raise "Too poor. Sorry." unless available_balance >= @amount + 1
    raise "Min transfer amount: #{min_amount}#{@currency}" if @amount < min_amount
  end

  def randomize_amount
    lower = [1, @params.shift.to_i].min
    upper = [@params.shift.to_i, available_balance].max
    @amount = rand(lower..upper)
    @result[:icon_emoji] = ":black_joker:"
  end

  def available_balance
     client.getbalance(@user_id)
  end

  def user_address(user_id)
     existing = client.getaddressesbyaccount(user_id)
    if (existing.size > 0)
      @address = existing.first
    else
      @address = client.getnewaddress(user_id)
    end
  end

  def help
    @result[:text] = "Possible commands: `#{ACTIONS.join('`, `' )}`\n" +
      "`#{@command} balance` - Show your balance\n" +
      "`#{@command} tip @username AMOUNT` - Send AMOUNT coins to @username\n" +
      "`#{@command} deposit` - Show your address to deposit coins into\n" +
      "`#{@command} withdraw ADDRESS AMOUNT` - Send AMOUNT coins to ADDRESS\n" +
      "`#{@command} networkinfo` - Show network info\n" +
      "`#{@command} help` - Show this message"
  end

end

