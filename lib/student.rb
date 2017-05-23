require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :name,:grade,:id
  def initialize(id = nil,name, grade)
    @name,@grade,@id = name,grade,id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(student_ary)
    id, name, grade = student_ary
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map {|student| self.new_from_db(student)}.first
  end
end
