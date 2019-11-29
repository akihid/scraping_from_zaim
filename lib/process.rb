require './lib/user'
require './lib/zaim'

def process
  puts "Zaimをスクレイピングして、家計簿の入力履歴を表示するコマンドラインツール"
  puts "\r\n------------------------------------------"

  user = User.new(ARGV[0], ARGV[1])
  # user = User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
  zaim = Zaim.new()

  unless zaim.login(user)
    # 再帰
    puts "入力された情報に誤りがあります。再入力してください。"
    puts "メールアドレス:#{user.mail} パスワード:#{user.password}"
    puts "\r\n------------------------------------------"
    process
  end

  obj = zaim.get_money_info(ARGV[2])
  until obj do
    obj = zaim.get_money_info(ARGV[2])
  end
  zaim.print_money_info()

end

process