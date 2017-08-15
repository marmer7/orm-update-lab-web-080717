require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :name, :grade, :id

  DB = DB[:conn]
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB.execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB.execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB.execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
        self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB.execute(sql, self.name, self.grade)
      self.id = DB.execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    row = DB.execute(sql, name)[0]
    self.new_from_db(row)
  end

end
