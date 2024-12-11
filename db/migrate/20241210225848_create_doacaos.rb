class CreateDoacaos < ActiveRecord::Migration[8.0]
  def change
    create_table :doacaos do |t|
      t.date :donation_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
