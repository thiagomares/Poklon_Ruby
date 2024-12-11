class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :full_name
      t.string :gender
      t.date :dob

      t.timestamps
    end
  end
end
