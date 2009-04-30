class CreateTranslations < ActiveRecord::Migration
	def self.up
		create_table :translations do |t|
			t.text :input
			t.text :output
			t.timestamps
		end
	end
end
