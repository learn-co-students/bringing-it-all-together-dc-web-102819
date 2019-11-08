require 'pry'

class Dog

	attr_accessor :name, :breed, :id

	def initialize(name:, breed:, id: nil)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed, TEXT);
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE dogs;
		SQL

		DB[:conn].execute(sql)
	end

	def self.new_from_db(params)
		# binding.pry
		new_dog = Dog.new(:name => nil, :breed => nil)
		new_dog.id = params[0]
		new_dog.name = params[1]
		new_dog.breed = params[2]
		new_dog		
	end

	def self.find_by_name(find_name)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ?;
		SQL

		result = DB[:conn].execute(sql, find_name)

		Dog.new_from_db(result[0])
	end

	def self.find_by_id(find_id)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE id = ?;
		SQL

		result = DB[:conn].execute(sql, find_id)
		# binding.pry
		Dog.new_from_db(result[0])
	end

	def self.create(params)
		new_dog = Dog.new(params)
		new_dog.save
		new_dog
	end

	def self.find_or_create_by(params)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?;
		SQL
		
		lookup = DB[:conn].execute(sql, params[:name], params[:breed])
		
		if !lookup.empty?
			input = lookup[0]
			dog = Dog.new(id: input[0], name: input[1], breed: input[2])
		else
			dog = self.create(params)
		end

		dog
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed)
				VALUES (? , ?);
			SQL

			DB[:conn].execute(sql, self.name, self.breed)

			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
		end
		self
	end

	def update
		sql = <<-SQL
			UPDATE dogs SET name = ?, breed = ?
			WHERE id = ?;
		SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end
end