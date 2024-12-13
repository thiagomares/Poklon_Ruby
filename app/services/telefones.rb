class Telefones < Metodos
  def initialize(numero = nil, tipo = nil, user_id)
    @numero = numero
    @tipo = tipo
    @user_id = user_id
  end

  def validador_informacoes
    usuario = User.find_by(id: @user_id)
    telefones = Telefone.where(user_id: usuario.id).pluck(:numero)

    # Verifica se os dados básicos estão presentes
    return { msg: "Dados não encontrados", status: :not_found } if @numero.nil? || @tipo.nil? || usuario.nil?

    # Valida o tamanho do número
    return { msg: "Telefone inválido", status: :unprocessable_entity } if @numero.length < 10 || @numero.length > 11

    # Verifica se o telefone já está cadastrado
    return { msg: "Telefone já cadastrado", status: :conflict } if telefones.include?(@numero)


    { msg: "Validação bem-sucedida", status: :ok }
  end

  def busca_telefones
    usuario = User.find_by(id: @user_id)

    return { msg: "Usuário não encontrado", status: :not_found } if usuario.nil?

    telefones = Telefone.where(user_id: usuario.id)

    return { msg: "O usuário #{usuario.username} não tem telefones cadastrados", status: :not_found } if telefones.empty?

    grouped_telefone = telefones.group_by(&:user_id)

    grouped_telefone.map do |user_id, telefones|
      {
        user_id: user_id,
        telefones: telefones.map(&:numero)
      }
    end
  end
end
