# -*- encoding : utf-8 -*-
class AddQuantityToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :quantity, :integer
  end
end
