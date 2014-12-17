class AddPortfolioOwnerToSecurity < ActiveRecord::Migration
  def change
    add_column :securities, :portfolio_owner, :string
  end
end
