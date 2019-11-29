class User
  attr_reader :mail, :password

  def initialize(mail, password)
    if mail.nil?
      puts "ログイン用のメールアドレスを入力してください"
      @mail = gets.chomp
    else
      @mail = mail
    end
    if password.nil?
      puts "ログイン用のパスワードを入力してください"
      @password = gets.chomp
    else
      @password = password
    end
  end
end