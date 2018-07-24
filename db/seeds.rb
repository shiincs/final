# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# page = Nokogiri::HTML(RestClient.get("https://en.wikipedia.org/wiki/List_of_programming_languages"))   
# result = page.css('div.div-col ul').text.downcase

# skills=result.split("\n")
# # puts skills.class

# framework = Nokogiri::HTML(RestClient.get("https://en.wikipedia.org/wiki/Comparison_of_web_frameworks#JavaScript"))
# framework_result = framework.css('table.wikitable th.table-rh').text.downcase

# frameworks = framework_result.split("\n")

# skills.each do |skill|
#     Skill.create(skill_contents: skill)
# end

# frameworks.each do |framework|
#     Skill.create(skill_contents: framework)
# end

categories = ["웹", "앱", "빅데이터", "AI", "임베디드", "VR", "핀테크", "블록체인", "e-commerce", "게임", "소프트웨어"]
skills = ["angularjs", "asp.net", "backbone.js", "bootstrap", "c", "c++","c#", "cobol", "css", "curl", "coffeescript", "delphi", "django", "ecmascript", "ember.js", "erlang", "express.js", "flask", "fortran", "go", "haskell", "html", "java", "javascript", "keper", "lua", "meteor", "node.js", "objective-C", "pascal", "perl", "pl/sql", "php", "python", "r", "rails", "react", "ruby", "scala", "sinatra", "spring", "struts", "swift", "typescript", "unix-shell", "visualbasic", "vue.js", "sql"]

categories.each do |category|
    Category.create(category_contents: category)    
end

skills.each do |skill|
    Skill.create(skill_contents: skill)
end