require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name 
    @grade = grade 
    @id = id 
  end 

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT, 
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students 
    SQL
    DB[:conn].execute(sql)
  end 

  def save
    if self.id
      sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
    else 
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end 
  end 

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end 

  def self.new_from_db(array)
    student = Student.new(array[1], array[2], array[0])
    student
  end 

  def self.find_by_name(name)
    sql = "
    SELECT *
    FROM students 
    WHERE name = ?;"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end[0]
  end 

  def update
    sql = "
    UPDATE students
    SET name = ?, grade = ?;"
    DB[:conn].execute(sql, self.name, self.grade)
  end 
end
