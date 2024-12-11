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
      data_nascimento = Date.parse(dob) rescue nil

      if username.blank? || full_name.blank? || data_nascimento.nil?
        render json: { error: "Dados ausentes" }, status: :bad_request
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
end
