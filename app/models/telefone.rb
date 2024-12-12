class Telefone < ApplicationRecord
  belongs_to :user

  validates :numero, presence: true, length: { minimum: 10, maximum: 11, format: { with: /\A[0-9]+\z/ } }
  validates :tipo, presence: true, inclusion: { in: %w[celular fixo] }
  validates :user_id, presence: true
end
