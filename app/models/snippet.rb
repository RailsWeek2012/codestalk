class Snippet < ActiveRecord::Base
  attr_accessible :description, :language, :package, :source, :title, :user_id, :user, :package_id, :language_id
  belongs_to :user
  belongs_to :package
  belongs_to :language
  has_many :comments
end
