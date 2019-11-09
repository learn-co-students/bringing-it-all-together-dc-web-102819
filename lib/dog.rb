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
		sql = "DROP TABLE dogs;"
		DB[:conn].execute(sql)
    end
    
    def save
        if self.id
			self.update
		else
        sql = <<-SQL 
        INSERT INTO dogs (name,breed)
         VALUES (?, ?)
         SQL
        DB[:conn].execute(sql, self.name, self.breed)
    
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
      
      def self.create(hash)
        dog = Dog.new(hash[:name], hash[:breed])
        dog.save
        dog
      end
      def self.create(params)
		new_dog = Dog.new(params)
		new_dog.save
		new_dog
	end
    
    
    
    def self.new_from_db(row)
        new_dog = self.new({id: row[0], name: row[1], breed: row[2]})
        new_dog

    end

    	def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name =?"
        row = DB[:conn].execute(sql,name).first
        dog = self.new_from_db(row)
        dog
    end
    def self.find_by_id(find_id)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE id = ?;
		SQL

		result = DB[:conn].execute(sql, find_id)
		Dog.new_from_db(result[0])
    end

    def self.find_or_create_by(row)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?;
		SQL
        look = DB[:conn].execute(sql, row[:name],row[:breed])

		if !look.empty?
			input = look[0]
			dog = Dog.new(id: input[0], name: input[1], breed: input[2])
		else
			dog = self.create(row)
        end
        dog
    end
    def update
		sql = <<-SQL
			UPDATE dogs SET name = ?, breed = ?
			WHERE id = ?;
		SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
   
end
