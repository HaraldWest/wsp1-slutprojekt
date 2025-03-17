require 'sqlite3'

class Seeder
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS score')
    db.execute('DROP TABLE IF EXISTS users')
  end


  def self.create_tables
    db.execute('CREATE TABLE score (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      score INTEGER NOT NULL
    )')
    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password VARCHAR(255) NOT NULL
    )')
  end

  def self.populate_tables
    
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/score.sqlite')
    @db.results_as_hash = true
    @db
  end

end

# Run the seeder
Seeder.seed!
