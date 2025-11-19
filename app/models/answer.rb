class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :checklist
  
  validates :content, presence: true
end