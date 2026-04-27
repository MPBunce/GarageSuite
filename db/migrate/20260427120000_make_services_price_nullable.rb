class MakeServicesPriceNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :services, :price, true
  end
end
