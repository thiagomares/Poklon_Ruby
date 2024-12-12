class CreateTelefones < ActiveRecord::Migration[8.0]
  def change
    create_table :telefones do |t|
      t.string :numero
      t.string :tipo
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
