class AddDisabledToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :disabled, :boolean, default: false
  end
end
