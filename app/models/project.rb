class Project < ActiveRecord::Base
  attr_accessible :title, :description, :user_id, :user, :library_id, :library
  belongs_to :user
  belongs_to :library
  has_many :packages, dependent: :destroy
end
