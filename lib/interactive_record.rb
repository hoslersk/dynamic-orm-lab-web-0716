require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(options={})
    options.each do |property, value|
      #binding.pry
      self.send("#{property}=", value)
    end
  end

  def self.table_name
    table_name = self.to_s.downcase.pluralize
    #binding.pry
    #DB[:conn].execute("CREATE TABLE IF NOT EXISTS #{table_name} (id INTEGER PRIMARY KEY);")
  end

  def self.column_names
    column_names = []
    results = DB[:conn].execute("pragma table_info(#{self.table_name});")
    results.each do |column|
      #binding.pry
      column_names << column["name"]
    end
    #binding.pry
    column_names
  end

  # self.column_names.each do |column_name|
  #   attr_accessor column_name.to_sym
  # end

  def table_name_for_insert
    self.class.to_s.downcase.pluralize
  end

  def col_names_for_insert
    #binding.pry
    self.class.column_names.delete_if {|column_name| column_name == "id"}.join(", ")
  end

  def values_for_insert
    value_names = []
    self.class.column_names.each do |column_name|
      value_names << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    value_names.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{values_for_insert});")
    results = DB[:conn].execute("SELECT #{self.table_name_for_insert}.id FROM #{self.table_name_for_insert} ORDER BY #{self.table_name_for_insert}.id DESC LIMIT 1;")
    @id = results[0][0]
  end

  def self.find_by_name(name)
    #binding.pry
    results = DB[:conn].execute("SELECT * FROM #{self.table_name}") #WHERE #{self.table_name}.name = #{name};")
    #[{"id"=>1, "name"=>"Jan", "grade"=>10, 0=>1, 1=>"Jan", 2=>10}]
    #doesn't eliminate other rows, but encountering error otherwise:
    #SQLite3::SQLException: no such column: Jan
    results
  end

  def self.find_by(argument)
    #binding.pry
    results = DB[:conn].execute("SELECT * FROM #{self.table_name};") #WHERE #{self.table_name}.#{argument.keys.pop.to_s} = #{argument.values}")
    #same issue as above method (self.find_by_name)
    results
  end

end
