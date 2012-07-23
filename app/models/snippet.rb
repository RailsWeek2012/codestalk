class Snippet < ActiveRecord::Base
  attr_accessible :description, :language, :library, :source, :title, :user_id
  has_many :libraries
  belongs_to :user
end
