class Checklist < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  
  validates :content, presence: true, length: { maximum: 10000 }
  validates :question_type, presence: true
end