class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActiveRecord::WrappedTransaction
end

class Widget < ApplicationRecord
  validates_presence_of :name
end
