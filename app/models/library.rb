class Library < ActiveRecord::Base
  attr_accessible :title, :description, :user_id, :user
  belongs_to :user
  has_many :projects, dependent: :destroy
end
