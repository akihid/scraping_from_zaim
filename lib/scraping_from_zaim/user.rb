require "nokogiri"
require 'mechanize'

URL = "https://auth.zaim.net/".freeze
TARGET_URL = "https://zaim.net/money?month=".freeze

module ScrapingFromZaim
  class User
    def initialize(mail, password)
      @mail = mail
      @password = password

      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'
    end

    def login()
      page = @agent.get(URL)

      form = page.form_with(id: 'UserLoginForm')
      form.field_with(id: 'UserEmail').value = @mail
      form.field_with(id: 'UserPassword').value = @password

      logined_page = form.submit
      logined_page_source = logined_page.content.toutf8.to_s

      oath_url = logined_page_source.scan(/https:\/\/zaim\.net\/user_session\/callback\?oauth_token=\w+&oauth_verifier=\w+/)

      if oath_url.empty?
        puts "\r\n!Err! ログインに失敗しました。"
        return false
      end
      puts "\r\n!Ok! ログインに成功しました。"
      @agent.get(oath_url[0]) 
      return true
    end

    def get_money_info(month)  
      return false unless month_valid?(month)

      url = TARGET_URL + month
      page = @agent.get(url)
      doc = Nokogiri::HTML(page.content.toutf8)
    end

    private 

    def month_valid?(month)
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
end