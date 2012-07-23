class Library < ActiveRecord::Base
  attr_accessible :integer, :title, :user_id
  belongs_to :snippet
end
