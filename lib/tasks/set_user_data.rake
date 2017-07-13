# frozen_string_literal: true
namespace :setting_testdata do
  desc '検索のテストデータセット'
  task exec: :environment do
    ENV['RAILS_ENV'] ||= "development"
    Rails.logger.info '===データ作成開始==='
    user  = User.create(name: 'テスト太郎', age: 30, profile: 'ほげだぞ。俺はほげだ!!', gender: 1)
    1000.times do
      Rails.logger.info "book data save!"
      book = Book.create(
        title: ["#{[*1..100].sample}犬画像のサンプル", "映画ノベライズ#{[*1..100].sample}本", "サッカー関連の雑誌#{[*1..100].sample}", "#{[*1..100].sample}料理本"].sample,
        description: ["#{[*1..100].sample}犬の画像についてですかわいいですねー。", "好きな映画の小説版です。面白いですね", "サッカーやりたくなりますが、最新のサッカー関連の本です", "料理の本です。日本食、中華、などいろいろです"].sample,
        user: user
      )
    end

    Rails.logger.info('データ作成完了')
  end
end
