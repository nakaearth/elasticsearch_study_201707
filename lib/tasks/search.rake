# ローカル検証用のrakeタスクです
# 実行方法: bundle exec rake content_box_search:search_test
#
namespace :search do
  desc 'search test cbank_entries records with elasticsearch'
  task :search_test => :environment do
    params = {
      keyword: 'テスト',
    }

    search_start_time = Time.now

    users = TestSearch.new(params).search

    search_end_time = Time.now

    p users.to_a
    users.to_a.each do |user|
      puts '/===================================='
      puts "id: #{user.id}"
      puts "body: #{user.name}"
      puts "作成日付: #{user.created_at}"
      puts "===コメント==="
      user.books.each do | book |
        puts "book user_id: #{book.user_id}"
        puts "book title: #{book.title}"
      end
      puts '====================================/'
    end

    puts "検索処理時間：#{search_end_time - search_start_time }"
  end
end
