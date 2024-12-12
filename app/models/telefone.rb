class Telefone < ApplicationRecord
  belongs_to :user, foreign_key: :true

  validates :numero, presence: true, length: { minimum: 10, maximum: 11 }
  validates :tipo, presence: true, inclusion: { in: %w[celular fixo] }
  validates :user_id, presence: true
end
