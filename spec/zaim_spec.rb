require 'spec_helper.rb'

describe 'zaimスクレイピングテスト' do
  
  context 'ログインのテスト' do
    before(:all) do
      @user = ScrapingFromZaim::User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @ng_user = ScrapingFromZaim::User.new("hoge_fuga_ho-999@yahoo.co.jp", "hogefuga")
    end

    it 'User情報に誤りがある場合、ログインできない' do
      VCR.use_cassette("login_zaim_ng") do
        expect(@ng_user.login()).to eq(false)
      end
    end

    it 'User情報が正しい場合、ログインできる' do
      VCR.use_cassette("login_zaim_ok") do
        expect(@user.login()).to eq(true)
      end
    end
  end

  context '入力履歴表示のテスト' do

    before(:all) do
      @user = ScrapingFromZaim::User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      VCR.use_cassette("login_zaim_ok") do
        @user.login()
      end
      @zaim = ScrapingFromZaim::Zaim.new()
    end

    it '入力履歴がない年月を指定した場合、何も表示されない' do 
      VCR.use_cassette("get_money_info_201909") do
        doc = @user.get_money_info("201909")
        expect(@zaim.print_process(doc, "201909")).to eq(false)
      end
    end

    it '入力履歴がある年月を指定した場合、表示される' do
      VCR.use_cassette("get_money_info_201910") do
        doc = @user.get_money_info("201910")
        expect(@zaim.print_process(doc, "201910")).to eq(true)
      end
      VCR.use_cassette("get_money_info_201911") do
        doc = @user.get_money_info("201911")
        expect(@zaim.print_process(doc, "201911")).to eq(true)
      end
    end
  end

  context '入力履歴表示内容のテスト' do

    before(:all) do
      @user = ScrapingFromZaim::User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @zaim = ScrapingFromZaim::Zaim.new()
      VCR.use_cassette("login_zaim_ok") do
        @user.login()
      end
      VCR.use_cassette("get_money_info_201911") do
        @doc =  @user.get_money_info("201911")
      end
    end

    it '日付が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.date > a.edit-money').map{|data| data.text() }).to include "11月29日（金）\n"
    end

    it 'カテゴリーが取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.category > a.edit-money').map{|data| data.text() }).to include "給与所得\n"
    end

    it '価格が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.price > a.edit-money').map{|data| data.text() }).to include "¥220,000\n"
    end

    # 入金・出金はテストデータ作成不可のため、未実施
    # it '出金が取得できている' do 
    #   expect(@doc.css('table.list > tbody.money-list').css('td.from_account > a.edit-money > img').map{|data| data.get_attribute('data-title') }).to include ""
    # end

    # it '入金が取得できている' do 
    #   expect(@doc.css('table.list > tbody.money-list').css('td.to_account > a.edit-money > img').map{|data| data.get_attribute('data-title') }).to include ""
    # end

    it 'お店が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.place > a.edit-money > span').map{|data| data.get_attribute('title') }).to include "コンビニ"
    end

    it '品目が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.name > div.name > a.edit-money > span').map{|data| data.get_attribute('title') }).to include "接待費"
    end

    it 'メモが取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.comment > div.comment > a.edit-money > span').map{|data| data.get_attribute('title') }).to include "コーヒーのみ"
    end

    it '支出の合計が取得できている' do 
      expect(@doc.css('table.amount_summary').css('td.money_payment_amount').text()).to include "¥25,360\n"
    end

    it '収入の合計が取得できている' do 
      expect(@doc.css('table.amount_summary').css('td.money_income_amount').text()).to include "¥220,000\n"
    end
    it '総額が取得できている' do 
      expect(@doc.css('table.amount_summary').css('td.money_total_amount').text()).to include "¥194,640\n"
    end

  end

  context '指定年月チェックのテスト' do
    before(:all) do
      @user = ScrapingFromZaim::User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @zaim = ScrapingFromZaim::Zaim.new()
      VCR.use_cassette("login_zaim_ok") do
        @user.login()
      end
    end

    it '年月にyyyyMM形式以外を指定した場合、エラーとなる(6桁以外）' do
      VCR.use_cassette("get_money_info_err") do
        expect(@user.get_money_info("20191")).to eq(false)
      end
    end

    it '年月にyyyyMM形式以外を指定した場合、エラーとなる(数値以外）' do
      VCR.use_cassette("get_money_info_err") do
        expect(@user.get_money_info("あいうえおか")).to eq(false)
      end
    end

    it '年月にyyyyMM形式以外を指定した場合、エラーとなる(存在しない年月）' do 
      VCR.use_cassette("get_money_info_err") do
        expect(@user.get_money_info("201913")).to eq(false)
      end
    end 
  end
end