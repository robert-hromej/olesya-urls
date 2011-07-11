Factory.define :user do |user|
  user.screen_name "name"
  user.oauth_token "token"
  user.oauth_secret "secret"
end

Factory.sequence :screen_name do |n|
  "name-#{n}"
end

Factory.define :link do |link|
  link.title "title"
  link.url "url"
  link.association :user
end

Factory.define :comment do |comment|
  comment.body "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed congue dictum turpis, in sagittis lorem dignissim nec. Sed ultricies augue ut metus sollicitudin porttitor. In molestie lacinia sapien eget interdum. Aenean scelerisque urna sed felis blandit vestibulum. Donec lobortis porttitor magna non viverra."
  comment.association :link
  comment.association :user
end

