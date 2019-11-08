class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(hash)
        @id = hash[:id]
        @name = hash[:name]
        @breed = hash[:breed]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL
        
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
            SQL
        
        DB[:conn].execute(sql)
    end

    def self.create(dog_hash)
        created_dog = Dog.new(dog_hash)
        created_dog.save
    end

    def save
        if self.id
            update()
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
                SQL

            DB[:conn].execute(sql, self.name, self.breed)

            sql_return = <<-SQL
                SELECT * FROM dogs
                ORDER BY id DESC LIMIT 1;
                SQL
            
            returned_dog = DB[:conn].execute(sql_return)[0]
            @id = returned_dog[0]
            Dog.new_from_db(returned_dog)
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs 
            SET name = ?, breed = ?
            WHERE id = ?;
            SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.new_from_db(dog_data)
        dog_hash = {
            id: dog_data[0],
            name: dog_data[1],
            breed: dog_data[2]
        }
        Dog.new(dog_hash)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? LIMIT 1;
            SQL

        queried_dog_data = DB[:conn].execute(sql, name)
        Dog.new_from_db(queried_dog_data[0])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ? LIMIT 1;
            SQL
        
        queried_dog_data = DB[:conn].execute(sql, id)
        Dog.new_from_db(queried_dog_data[0])
    end

    def self.find_or_create_by(dog_hash)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?;
            SQL

        queried_dog_data = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])

        unless queried_dog_data.length > 0
            Dog.create(dog_hash)
        else
            Dog.new_from_db(queried_dog_data[0])
        end
    end
end