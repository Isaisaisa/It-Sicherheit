class AddMailChangeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :future_email, :string
    add_column :users, :email_change_digest, :string
    add_column :users, :email_change_sent_at, :datetime
  end
end
