class RenameOauthLoginToToken < ActiveRecord::Migration

  def change
    rename_column :users, :oauth_login, :oauth_token
  end

end
