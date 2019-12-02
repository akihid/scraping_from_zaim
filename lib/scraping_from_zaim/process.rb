require 'thor'

module ScrapingFromZaim
  class CLI < Thor
    package_name "scraping_zaim"
    default_command :process

    desc "process {mail} {password} {yyyymm}", "get histroy_info from zaim"
    option :mail, desc: "process mail", type: :string, default: "", aliases: :m
    option :password, desc: "process password", type: :string, default: "", aliases: :p
    option :yyyymm, desc: "process yyyymm", type: :string, default: "", aliases: :y
    def process
      puts "Zaimをスクレイピングして、家計簿の入力履歴を表示するコマンドラインツール"
      puts "------------------------------------------\r\n"

      mail = get_value_from_arg(options[:mail], "ログイン用のメールアドレスを入力してください")
      password = get_value_from_arg(options[:password], "ログイン用のパスワードを入力してください")

      # 変数でuserをインスタンス化
      user = User.new(mail, password)

      # userをログインさせる(falseの場合、ログイン失敗のため終了)
      unless user.login()
        puts "入力された情報に誤りがあります。値を確認してください。"
        puts "メールアドレス:#{mail} パスワード:#{password}"
        puts "------------------------------------------\r\n"
        exit
      end

      # userがログインに成功していた場合、引数を取得、または入力させ表示する月を変数に代入。年月が不正な値の場合、終了
      month = get_value_from_arg(options[:yyyymm], "\r\n取得したい年月を入力してください(半角英数字6桁)(例:201911)")
      doc = user.get_money_info(month)

      exit unless doc

      zaim = Zaim.new() 
      zaim.print_process(doc, month)

    end

    private

    def get_value_from_arg(arg, msg)
      if arg.empty?
        puts msg
        result = STDIN.gets.chomp
      else
        result = arg
      end
    end

  end
end