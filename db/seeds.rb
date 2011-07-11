User.delete_all
Comment.delete_all
Link.delete_all
Vote.delete_all

users = []

User.transaction do
  %w{
      JaRa_ik BruSDD SenyaTwiter sprilukin wedmid Uzhtwevent tapac achipinthesugar MobFun carlsbergrussia otdelka7777777
      egie_sa maulyusf prithatya breaking_news__ JBuck27845 alexn1989 TheSpoiledKid qiixuan aleksandrit zurblog
      wedmid sarefan cimbory_com veta_veta zipskiy DefBreath zadrotco mrNazareno dyrnuchka biznesoblast AndriySalyga
      buzeychuk ukrayinec jobber4IT regseo FashionTimee adriana_fedkiv sexdrugshatred MafiaUkraina ylitka_com_ua
      LouzhnikiTravel Hutriii HeidiqHayden proavt Oleksandr_Drozd flashbaggg Romanenchuk m_kobernyk Lynx_O 100krokiv
  }.each do |screen_name|
    user = User.new
    user.screen_name = screen_name
    user.oauth_token = "oauth_token"
    user.oauth_secret = "oauth_secret"
    user.save
    users << user
  end
end

links = []
Link.transaction do
  [
      "http://www.botsvsbrowsers.com/details/415562/index.html",
      "http://russian.railstutorial.org/chapters/beginning#sec:install_git",
      "http://railscasts.com/episodes/66-custom-rake-tasks",
      "http://www.harrypotterwallart.com/posters-scenes/professor-dolores-umbridge-montage-poster-with-framed-proclamation/mpsfi/923b42ed-53aa-4e63-bc49-ac85a90f4d1b",
      "https://github.com/blog/517-unicorn",
      "http://unicorn.bogomips.org/",
      "http://www.engineyard.com/blog/2010/everything-you-need-to-know-about-unicorn/",
      "http://habrahabr.ru/blogs/ror/120368/",
      "http://sirupsen.com/setting-up-unicorn-with-nginx/",
      "http://tech.tomgoren.com/archives/245",
      "http://habrahabr.ru/company/zfort/blog/123536/",
      "http://railscasts.com/",
      "http://railscasts.com/episodes/273-geocoder?autoplay=true",
      "http://railscasts.com/episodes/272-markdown-with-redcarpet?autoplay=true",
      "http://railscasts.com/episodes/271-resque?autoplay=true",
      "http://railscasts.com/episodes/270-authentication-in-rails-3-1?autoplay=true",
      "http://railscasts.com/episodes/269-template-inheritance?autoplay=true",
      "http://railscasts.com/episodes/267-coffeescript-basics?autoplay=true",
      "http://railscasts.com/episodes/266-http-streaming?autoplay=true",
      "http://www.harrypotterwallart.com/new-images",
      "http://www.harrypotterwallart.com/retail-packages",
      "http://www.harrypotterwallart.com/harry",
      "http://www.harrypotterwallart.com/witches-wizards",
      "http://www.harrypotterwallart.com/hogwarts",
      "http://www.harrypotterwallart.com/posters-scenes",
      "http://www.harrypotterwallart.com/quidditch",
      "http://www.harrypotterwallart.com/spells-artifacts",
      "http://www.harrypotterwallart.com/the-dark-arts",
      "http://www.harrypotterwallart.com/wizarding-world",
      "http://www.harrypotterwallart.com/wizarding-world",
      "http://www.harrypotterwallart.com/creatures",
      "http://www.harrypotterwallart.com/bundles",
      "http://www.ruby-lang.org/en/",
      "http://www.ruby-lang.org/en/downloads/",
      "http://rubyonrails.org/",
      "http://uk.wikipedia.org/wiki/Ruby",
      "http://ru.wikipedia.org/wiki/Ruby",
      "http://en.wikipedia.org/wiki/Ruby_(programming_language)",
      "http://rubyinstaller.org/",
      "http://ru.wikibooks.org/wiki/Ruby",
      "http://habrahabr.ru/blogs/ruby/",
      "http://www.mystyle.com/mystyle/shows/ruby/index.jsp",
      "http://rubyonrails.org/documentation",
      "http://uk.wikipedia.org/wiki/Ruby_on_Rails",
      "http://ru.wikipedia.org/wiki/Ruby_on_Rails",
      "http://en.wikipedia.org/wiki/Ruby_on_Rails",
      "http://habrahabr.ru/blogs/ror/",
      "http://oreilly.com/ruby/archive/rails.html"
  ].each do |url|
    begin
      link = Link.new
      link.user_id = users.shuffle.first.id
      link.title = "title..."
      link.url = url
      link.save
      links << link
    rescue ActiveRecord::StatementInvalid => e
    end
  end
end

comments = ["Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            " Lorem Ipsum has been the industry's standard dummy",
            " text ever since the 1500s, when an unknown printer took",
            " a galley of type and scrambled it to make a",
            "type specimen book. It has survived not only five centuries",
            " but also the leap into electronic typesetting, remaining essentially",
            " unchanged. It was popularised in the 1960s with the release of Letraset",
            " sheets containing Lorem Ipsum passages, and more recently with desktop",
            " publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
            "Ruby on Rails Tutorial owes a lot to my previous Rails book, RailsSpace, and hence to my coauthor Aurelius Prochazka.",
            " I’d like to thank Aure both for the work he did on that book and for his support of this one.",
            " I’d also like to thank Debra Williams Cauley, my editor on both RailsSpace and Rails Tutorial;",
            "as long as she keeps taking me to baseball games, I’ll keep writing books for her.",
            "Finally, many, many readers—far too many to list—have contributed a huge number of bug reports and suggestions during the writing of this book",
            "and I gratefully acknowledge their help in making it as good as it can be. ",
            "Ruby on Rails Tutorial follows essentially the same approach as my previous Rails book,",
            "2 teaching web development with Rails by building a substantial sample application from scratch. ",
            "As Derek Sivers notes in the foreword, this book is structured as a linear narrative, designed to be read from start to finish. ",
            "If you are used to skipping around in technical books, taking this linear approach might require some adjustment, ",
            "but I suggest giving it a try. You can think of Ruby on Rails Tutorial as a video game where you are the main character, ",
            "and where you level up as a Rails developer in each chapter. (The exercises are the minibosses.)"

]

Comment.transaction do
  links.each do |link|
    coms = comments.shuffle
    rand(comments.size).times do |i|
      comment = Comment.new
      comment.user_id = users.shuffle.first.id
      comment.link_id = link.id
      comment.body = coms[i]
      comment.save
    end
  end
end

Vote.transaction do
  links.each do |link|
    us = users.shuffle
    rand(users.size).times do |i|
      v = Vote.new
      v.user_id = us[i].id
      v.link_id = link.id
      v.kind = rand(2)
      v.save
    end
  end
end

