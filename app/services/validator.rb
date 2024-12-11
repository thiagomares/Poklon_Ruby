# frozen_string_literal: true

class Validator
  attr_accessor :id, :date, :data_ultima, :gender

  def initialize(id, date, data_ultima, gender)
    @id = id
    @date = parse_date(date)
    @data_ultima = parse_date(data_ultima)
    @gender = gender
  end

  def parse_date(value)
    value.is_a?(String) ? Date.parse(value) : value
  end

  def confirma_doacao
    raise "Data de doação não pode ser nula" if @date.nil?

    anos_diferenca = @date.year - @data_ultima.year
    meses_diferenca = @date.month - @data_ultima.month

    total_meses = (anos_diferenca * 12) + meses_diferenca

    if @gender == "M"
      # Homens não podem doar antes nem depois de 2 meses
      if total_meses.abs <= 2
        false
      else
        true
      end
    elsif @gender == "F"
      # Mulheres não podem doar em um intervalo de 3 meses
      if total_meses.abs <= 3
        false
      else
        true
      end
    else
      false
    end
  end

  def datas_iguais
    if @date == @data_ultima || @date < @data_ultima
      false
    end
  end
end
