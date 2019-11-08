class Dog

    attr_accessor :name, :breed, :id

    def initialize (attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
    end

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
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
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql,self.name,self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end

    def self.create(attributes)
        new_dog = self.new(attributes)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new({id: row[0], name: row[1], breed: row[2]})
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql,id).first
        dog = self.new_from_db(row)
        dog
    end

    def self.find_or_create_by(attributes)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", attributes[:name], attributes[:breed])
        if !dog.empty?
            self.new_from_db(dog.first)
        else 
            self.create(attributes)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name =?"
        row = DB[:conn].execute(sql,name).first
        dog = self.new_from_db(row)
        dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end