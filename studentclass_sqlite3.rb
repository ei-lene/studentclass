
#find methods: by ID and find by name.
#save methods to update - might need to teach students if they are in the database.

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'SQLite3'
require 'pry'

INDEX = "http://students.flatironschool.com/"
INDEX_DOC = Nokogiri::HTML(open(INDEX))

student_urls = INDEX_DOC.css("div.one_third > a").map do |a| 

    (INDEX + a.attr("href")).sub("/.", "" )

end

# puts student_urls


class Student
  attr_accessor :id, :name, :tagline, :intro_paragraph, :social_links, :work, :education, :coder_cred, :blog_link, :fav_companies, :fav_websites, :quotes
   #create database
  @@db = SQLite3::Database.new "students.db" 

   #create table in database "students" with columns
  @@db.execute ( "create table if not exists students (id INTEGER PRIMARY KEY, name TEXT, tagline TEXT, intro_paragraph TEXT, social_links TEXT, work TEXT, education TEXT, coder_cred TEXT, blog_link TEXT, fav_companies TEXT, fav_websites TEXT, quotes TEXT);")

  def initialize(params={}) #function that will automatically be called when you create a new instance of the class.
    @id = params[:id]
    @name = params[:name]
    @tagline = params[:tagline]
    @intro_paragraph = params[:intro_paragraph]
  end

  def self.find_by_name(name)
    result = @@db.execute("SELECT * FROM students WHERE name = ?", name)
    Student.new(:id => result[0][0],:name =>result[0][1], :tagline =>result[0][2], :intro_paragraph =>result[0][3])
  end

   #insert values in the columns
  def save
    #binding.pry
    if self.class.find_by_name(@name)
    @@db.execute(
    "INSERT INTO students (name, tagline, intro_paragraph, social_links) VALUES (
    ?, ?, ?, ?);", [@name, @tagline, @intro_paragraph, @social_links]
    )
    @id = @@db.execute("SELECT id FROM students WHERE name = ?;", [@name])
    else
    @@db.execute(
    "UPDATE students (name, tagline, intro_paragraph, social_links) VALUES (
    ?, ?, ?, ?);", [@name, @tagline, @intro_paragraph, @social_links]
    )
    end
  end
   
   #insert info in the columns
  # @@db.execute("INSERT INTO students (name, tagline, intro_paragraph, social_links, work, 
  #   education, coder_cred, blog_link,fav_companies, fav_websites, quotes) VALUES (?, ?, ?, ?, ?, 
  #   ?, ?, ?, ?, ?, ?)", [@name, @tagline, @intro_paragraph, @social_links, @work, 
  #   @education, @coder_cred, @blog_link, @fav_companies, @fav_websites, @quotes]
  # )


#take url away from initialize so i can create new students who arent cool enough to have webpages
#find another way to chain the methods on objects of the class so it will scrape its data- 
#but can only want to open each student site once to




  def scrape_and_insert(url)
    begin
    @doc = Nokogiri::HTML(open(url))
    self.scrape_name
    self.scrape_tagline
    self.scrape_student_intro_paragraph
    self.scrape_social_links
    self.scrape_work
    self.scrape_education
    self.scrape_coder_cred
    self.scrape_blog_link
    self.scrape_fav_companies
    self.scrape_fav_websites
    self.scrape_quotes
    self.save

  rescue => ex
    puts "except #{ex} on #{url}"
      yield ex
    end
  end

  def self.all
    students = []
    result = @@db.execute("SELECT * FROM students")
    result.each do |result|
      students << Student.new(:id => result[0],:name =>result[1], :tagline =>result[2], :intro_paragraph =>result[3])
    end
    students
  end

  # result = ['dog', 'cat', 'horse']
  # result[1]

  def self.find(id)
    result = @@db.execute("SELECT * FROM students WHERE id = ?", id)
    #binding.pry
    Student.new(:id => result[0][0],:name =>result[0][1], :tagline =>result[0][2], :intro_paragraph =>result[0][3])
  end

  # result = [['dog', 'mouse'], ['cat'], ['horse']]
  # result= [dog, cat, horse]
  # result[0]
  # result[0][0]



    #syntax for updating table data:
    # UPDATE person SET first_name = "Hilarious Guy"
    # WHERE first_name = "Zed";

  # def self.update_name(name)
  #   rows = @@db.execute("UPDATE students SET name='(var)' where name =  ")
  # end

  def scrape_name
    self.name = @doc.css("h1").inner_text
  end

  def scrape_tagline
    self.tagline = @doc.css("section#about h2").text
  end

  def scrape_student_intro_paragraph
    self.intro_paragraph = @doc.css("section#about p:nth(1)").text
  end

  # def scrape_social_links
  #   self.social_links = @doc.css("div.social_icons a").map do |social_link|
  #     social_link.attr("href")
  #   end
  # end

  def scrape_social_links
    self.social_links = (@doc.css("div.social_icons a").map do |social_link|
      social_link.attr("href")
    end).join(", ")
  end

  def scrape_work
    self.work = @doc.css("section#former_life div.one_half:nth(1) li a").map do |a|
      description = a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_education
    self.education = @doc.css("section#former_life div.one_half.last ul li a").map do |a|
      description = a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_coder_cred
    self.coder_cred = @doc.css(".columns.coder_cred td a").map do |a|
      a.attr("href")
    end
  end

  def scrape_blog_link
    self.blog_link = @doc.css(".columns.coder_cred div p a").map do |a|
      a.attr("href")
    end
  end

  def scrape_fav_companies
    self.fav_companies = @doc.css("#favorites div.columns:nth(1) a") do |a|
      description= a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_fav_websites
    self.fav_websites = @doc.css("#favorites div.columns:nth(2) a") do |a|
      description = a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_quotes
    self.quotes = @doc.css(".one_fourth p").text
  end

end


student_urls.each do |student|
  begin
    Student.new.scrape_and_insert(student)
  rescue => e
    puts "Error creating #{student}: #{e}"
    next
  end
end

#find all student's names in the array:
# students.each do |student|
#   puts student.name
# end



