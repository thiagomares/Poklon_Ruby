class AddTipoSanguineo < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :tipo_sanguineo, :string
  end
end
