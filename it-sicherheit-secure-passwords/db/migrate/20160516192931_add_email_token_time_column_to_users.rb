class AddEmailTokenTimeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_token_time, :datetime
  end
end
