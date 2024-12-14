class Necessitantes < Metodos
  # O que é essa classe?
  # Precisamos cruzar as necessidades dos doadores com os dados dos necessitantes para encontrar o match perfeito

  attr_accessor :tipo_sanguineo

  def initialize(tipo_sanguineo)
    @tipo_sanguineo = tipo_sanguineo
  end

  def validador_informacoes
    # Nos vamos verificar todos os usuários que tem este tipo sanguíneo
    usuario = User.joins(:doacaos, :telefones).find_by(tipo_sanguineo: @tipo_sanguineo)

    total_doacoes = Doacao.where(user_id: usuario.id)
                          .where("strftime('%Y', donation_date) = ?", Date.today.year.to_s)
                          .count

    ultima_doacao = Doacao.where(user_id: usuario.id)
                          .where("strftime('%Y', donation_date) = ?", Date.today.year.to_s)
                          .order(donation_date: :desc)
                          .first

    # Aqui que verificamos as regras, nenhum ser humano pode doar mais do que 4 vezes no ano
    if total_doacoes < 4
      {
        usuario: usuario.id,
        username: usuario.username,
        nome_completo: usuario.full_name,
        tipo_sanguineo: usuario.tipo_sanguineo,
        telefones: usuario.telefones.pluck(:numero).distinct, # Assumindo que o relacionamento está correto
        ultima_doacao: ultima_doacao ? ultima_doacao.donation_date : nil, # Acessando diretamente a data da última doação
        total_doacoes: total_doacoes,
        status: :ok
      }
    else
      { error: "Limite de doações atingido", status: :unprocessable_entity }
    end
  end
end
