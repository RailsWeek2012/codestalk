class Package < ActiveRecord::Base
  attr_accessible :title, :description, :user_id, :user, :project
  belongs_to :user
  belongs_to :project
  has_many :snippets, dependent: :destroy
end
