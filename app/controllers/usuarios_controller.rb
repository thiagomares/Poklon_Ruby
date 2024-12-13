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
      user_id = params[:user_id]
      numero = params[:numero]
      tipo = params[:tipo]

      validando_telefone = Telefones.new(numero, tipo, user_id)
      validacao = validando_telefone.validador_informacoes

      if validacao[:status] == :ok
        telefone = Telefone.create!(numero: numero, tipo: tipo, user_id: user_id)
        render json: telefone, status: :created
      else
        render json: { msg: validacao[:msg] }, status: validacao[:status]
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "Erro inesperado: #{e.message}" }, status: :internal_server_error
    end
  end


  def retorna_telefone
    begin
      user_id = params[:user_id]

      busca_telefones = Telefones.new(nil, nil, user_id)
      resultado = busca_telefones.busca_telefones

      if resultado.is_a?(Array)
        render json: resultado, status: :ok
      else
        render json: { msg: resultado[:msg] }, status: resultado[:status]
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: "Erro inesperado: #{e.message}" }, status: :internal_server_error
    end
  end
end
