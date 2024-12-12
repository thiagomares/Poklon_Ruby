class UsuariosController < ApplicationController
  def index
    @usuarios = User.all
    render json: @usuarios
  end

  def cria_usuario
    begin
      username = params[:username]
      full_name = params[:full_name]
      gender = params[:gender]
      dob = params[:dob]
      tipo_sanguineo = params[:tipo_sanguineo]
      data_nascimento = Date.parse(dob)

      if username.blank? || full_name.blank? || data_nascimento.nil?
        render json: { error: "Dados ausentes" }, status: :bad_request
        return
      end

      soma_data_nascimento = data_nascimento.year - Date.today.year

      if soma_data_nascimento.abs <= 16
        render json: { error: "Usuário menor de idade" }, status: :unprocessable_entity
        return
      end

      if username != User.find_by(username: username)&.username
        user = User.create(username: username, full_name: full_name, gender: gender, dob: data_nascimento, tipo_sanguineo: tipo_sanguineo)
        if user.save
          render json: user, status: :created
        else
          render json: { error: "Erro ao criar o usuário" }, status: :unprocessable_entity
        end
      else
        render json: { error: "Usuário já existe" }, status: :conflict
      end

    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def adiciona_telefone
    begin
      user = params[:user_id]
      numero = params[:numero]
      tipo = params[:tipo]

      if user.blank? || numero.blank? || tipo.blank?
        render json: { error: "Dados ausentes" }, status: :bad_request
        return
      end

      usuario = User.find_by(id: user)

      if user.nil?
        render json: { error: "Usuário não encontrado" }, status: :not_found
        return
      end

      telefones_guardados = Telefone.where(user_id: usuario.id).pluck(:numero)

      telefones_guardados.each do |telefone_guardado|
        if telefone_guardado == numero
          render json: { error: "Telefone já cadastrado" }, status: :conflict
          return
        end
      end

      telefone = Telefone.create(numero: numero, tipo: tipo, user_id: usuario.id)
      render json: telefone, status: :created

    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def retorna_telefone
    begin
      user = User.find(params[:id])

      if user.nil?
        render json: { error: "Usuário não encontrado" }, status: :not_found
        return
      end

      telefone = Telefone.find_by(user_id: user.id)

      if telefone.nil?
        render json: { error: "Telefone não encontrado" }, status: :not_found
      else
        grouped_telefone = telefone.group_by { |telefone| telefone.user_id }

        render json: grouped_telefone.map { |user_id, telefones|
          {
            user_id: user_id,
            telefones: telefones.map { |telefone| telefone.numero }
          }
        }
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end
  end
end
