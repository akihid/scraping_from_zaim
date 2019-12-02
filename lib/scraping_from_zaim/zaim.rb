module ScrapingFromZaim
  class Zaim

    def print_process(doc, month)
      unless doc_empty?(doc)
        print_money_info(doc, month)
        return true
      end
      return false
    end

    private

    def print_money_info(doc, month)
      detail_doc = doc.css('table.list > tbody.money-list')
      total_doc = doc.css('table.amount_summary')

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
      puts "#{month[0, 4]}年#{month[4, 2]}月の入力履歴"
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
    end

    def doc_empty?(doc)
      detail_doc = doc.css('table.list > tbody.money-list')
      if detail_doc.empty?
        puts "\r\n!Err! 該当月のデータは存在しません。"
        return true
      end
      false
    end

    def print_format(title, value)
      value = "-" if value.nil?
      value = "-" if value.empty?
      puts title.ljust(6, '　') + value.gsub(/\r\n|\r|\n|\s|\t/, "")
    end


  end
end