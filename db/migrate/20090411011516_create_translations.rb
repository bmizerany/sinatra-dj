class CreateTranslations < ActiveRecord::Migration
	def self.up
		create_table :translations do |t|
			t.text :input
			t.text :output
      t.boolean :displayed, :default => false
			t.timestamps
		end
	end
end
