class Telefone < ApplicationRecord
  belongs_to :user

  validates :numero, presence: true, length: { minimum: 10, maximum: 11, format: { with: /\A[0-9]+\z/ } }
  validates :tipo, presence: true, inclusion: { in: %w[celular fixo] }
  validates :user_id, presence: true

  after_initialize do |telefone|
    if telefone.new_record?
      # Definimos o tipo de telefone como "celular" caso não seja informado
      telefone.tipo ||= "celular"
      if telefone.numero.nil?
        Rails.logger.info("Número de telefone não informado")
      end
    end
  end

  before_commit do |telefone|
    if telefone.numero.present?
      # Removemos caracteres não numéricos do número de telefone
      telefone.numero = telefone.numero.gsub(/\D/, "")
      Rails.logger.info("Número de telefone formatado: #{telefone.numero}")
    end
  end
end
