require './studentclass_sqlite3.rb'

def test(title, &b)
begin
if b
result = b.call
if result.is_a?(Array)
puts "fail: #{title}"
puts " expected #{result.first} to equal #{result.last}"
elsif result
puts "pass: #{title}"
else
puts "fail: #{title}"
end
else
puts "pending: #{title}"
end
rescue => e
puts "fail: #{title}"
puts e
end
end
 
def assert(statement)
!!statement
end
 
def assert_equal(actual, expected)
if expected == actual
true
else
[expected, actual]
end
end
 
test 'should be able to instantiate a student' do
assert Student.new
end
 
test 'should be able to save a student with a name' do
s = Student.new
s.name = "Avi Flombaum"
s.save
 
assert_equal Student.find_by_name("Avi Flombaum").name, "Avi Flombaum"
end
 
test 'should be able to load all students' do
s = Student.new
s.name = "Avi Flombaum"
s.save
 
assert Student.all.collect{|s| s.name}.include?("Avi Flombaum")
end
 
test 'should be able to find a student by id' do
s = Student.new
s.name = "Avi Flombaum"
s.save
 
assert_equal Student.find(s.id).name, "Avi Flombaum"
end
 
test 'should be able to update a student' do
s = Student.new
s.name = "Avi Flombaum"
s.save
 
s.name = "Bob Whitney"
s.save
 
assert_equal Student.find(s.id).name, "Bob Whitney"
end