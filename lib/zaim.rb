require "nokogiri"
require 'mechanize'
require "date"
require './lib/user'

URL = "https://auth.zaim.net/"
TARGET_URL = "https://zaim.net/money?month="

class Zaim
  def initialize()
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'
  end

  def login(user)
    page = @agent.get(URL)

    form = page.form_with(id: 'UserLoginForm')
    form.field_with(id: 'UserEmail').value = user.mail
    form.field_with(id: 'UserPassword').value = user.password

    logined_page = form.submit
    logined_page_source = logined_page.content.toutf8.to_s

    oath_url = logined_page_source.scan(/https:\/\/zaim\.net\/user_session\/callback\?oauth_token=\w+&oauth_verifier=\w+/)
    if oath_url.empty?
      puts "\r\n!Err! ログインに失敗しました。"
      return false
    end
    puts "\r\n!Ok! ログインに成功しました。"
    @agent.get(oath_url[0]) 
    @logined = true
  end

  def get_money_info(month)
    return false unless login_check()

    if month.nil?
      puts "\r\n取得したい年月を入力してください(半角英数字6桁)(例:201911)"
      @month = gets.chomp
    else
      @month = month
    end
    
    return false unless yyyymm_check(@month)

    url = TARGET_URL + @month
    page = @agent.get(url)
    @doc = Nokogiri::HTML(page.content.toutf8)
  end

  def print_money_info()
    detail_doc = @doc.css('table.list > tbody.money-list')
    total_doc = @doc.css('table.amount_summary')
    if detail_doc.empty?
      puts "\r\n!Err! 該当月のデータは存在しません。"
      return false
    end

    date_list = detail_doc.css('td.date > a.edit-money').map{|data| data.text() }
    category_list = detail_doc.css('td.category > a.edit-money').map{|data| data.text() }
    price_list = detail_doc.css('td.price > a.edit-money').map{|data| data.text() }
    from_account_list = detail_doc.css('td.from_account > a.edit-money > img').map{|data| data.get_attribute('data-title') }
    to_account_list = detail_doc.css('td.to_account > a.edit-money > img').map{|data| data.get_attribute('data-title') }
    place_list = detail_doc.css('td.place > a.edit-money > span').map{|data| data.get_attribute('title') }
    name_list = detail_doc.css('td.name > div.name > a.edit-money > span').map{|data| data.get_attribute('title') }
    comment_list = detail_doc.css('td.comment > div.comment > a.edit-money > span').map{|data| data.get_attribute('title') }
    payment_amount = total_doc.css('td.money_payment_amount').text()
    income_amount = total_doc.css('td.money_income_amount').text()
    total_amount = total_doc.css('td.money_total_amount').text()

    puts "------------------------------------------"
    puts "#{@month[0, 4]}年#{@month[4, 2]}月の入力履歴"
    puts "------------------------------------------"

    date_list.zip(category_list, price_list, from_account_list, to_account_list, place_list, name_list, comment_list) do |date, caregory, price, from_account, to_account, place, name, comment|
      print_format("日付", date)
      print_format("カテゴリ", caregory)
      print_format("金額", price)
      print_format("出金", from_account)
      print_format("入金", to_account)
      print_format("お店", place)
      print_format("品目", name)
      print_format("メモ", comment)
      puts "------------------------------------------"
    end

    print_format("支出の合計", payment_amount)
    print_format("収入の合計", income_amount)
    print_format("総額", total_amount)

    puts "------------------------------------------"
    true
  end

  private

  def print_format(title, value)
    value = "-" if value.nil?
    value = "-" if value.empty?
    puts title.ljust(6, '　') + value.gsub(/\r\n|\r|\n|\s|\t/, "")
  end

  def login_check()
    unless @logined
      puts "\r\n!Err! ログインしてください"
      return false
    end
    true
  end

  def yyyymm_check(month)
    unless month.length == 6
      puts "\r\n!Err! 6桁で入力してください(例:201911)"
      return false
    end

    if month.to_i == 0
      puts "\r\n!Err! YYYYMM形式で入力してください。(例:201911)"
      return false
    end

    begin
      Date.parse(month + "01")
    rescue
      puts "\r\n!Err! 存在する年月で入力してください(例:201911)"
      return false
    end

    true
  end


end