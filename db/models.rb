class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActiveRecord::WrappedTransaction
end

class Widget < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
