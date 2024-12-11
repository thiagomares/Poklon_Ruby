class DoacoesController < ApplicationController
  def index
    @doacoes = Doacao.includes(:user).all

    grouped_doacoes = @doacoes.group_by { |doacao| doacao.user.username }

    render json: grouped_doacoes.map { |username, doacoes|
      {
        username: username,
        donations: doacoes.map { |doacao| doacao.donation_date }
      }
    }
  end

  def por_usuario
    begin
      id = params[:username]
      if id.blank?
        render json: { error: "ID ausente" }, status: :bad_request
        return
      end

      # Encontre o usuário pelo username
      user = User.find_by(username: id)
      if user.nil?
        render json: { error: "Usuário não encontrado" }, status: :not_found
        return
      end

      # Agora busque as doações usando o user_id
      doacoes = Doacao.where(user_id: user.id)

      # Agrupar as doações por ano
      grouped_doacoes = doacoes.group_by { |doacao| doacao.donation_date.year }

      render json: grouped_doacoes.map { |year, doacoes_in_year|
        {
          year: year,
          donations: doacoes_in_year.map { |doacao| doacao.donation_date }
        }
      }
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Doação não encontrada: #{e.message}" }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end


  def marca_doacao
    begin
      id = params[:id]
      date = params[:date]
      pre_agendar = params[:pre_agendar]

      if id.blank? || date.blank?
        render json: { error: "ID ou data ausente" }, status: :bad_request
        return
      end

      date = Date.parse(date) rescue nil
      if date.nil?
        render json: { error: "Data inválida" }, status: :bad_request
        return
      end

      ano_da_data = date.year
      total_doacoes = Doacao.where(user_id: id)
                            .where("strftime('%Y', donation_date) = ?", ano_da_data.to_i)
                            .count

      excesso_agenda = Doacao.where("donation_date = ?", date).count

      if total_doacoes >= 3
        render json: { error: "Não pode agendar uma doação, pois está com volume elevado de doações." }, status: :unprocessable_entity
        return
      end

      doacoes = Doacao.where(user_id: id).pluck(:donation_date)
      gender = User.find(id).gender

      doacoes.each do |doacao|
        validador = Validator.new(id, date, doacao, gender)

        # Verifica se já existe uma doação agendada para a mesma data ou data anterior ou se o numero de agendamentos para a mesma data é maior que 20
        if !validador.confirma_doacao
          render json: { error: "Não pode agendar uma doação para a mesma data ou data anterior." }, status: :unprocessable_entity
          return
        elsif excesso_agenda >= 20
          render json: { error: "Não pode agendar uma doação, pois está com volume elevado de doações." }, status: :unprocessable_entity
          return
        end
      end

      if pre_agendar
        Doacao.create(user_id: id, donation_date: date)
        render json: { id: id, is_eligible: true, booked: true }, status: :ok
      else
        render json: { error: "Pre-agendamento não confirmado" }, status: :unprocessable_entity
      end

    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Usuário não encontrado: #{e.message}" }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def modifica_agendamento
  begin
    id = params[:id]
    id_doacao = params[:id_doacao]
    nova_data = params[:nova_data]

    if id.blank? || id_doacao.blank? || nova_data.blank?
      render json: { error: "campos inválidos" }, status: :bad_request
      nil
    end

    doacao = Doacao.find_by(id: id_doacao, user_id: id)
    doacoes = Doacoes.find(id).pluck(:donation_date)
    gender = User.find(id).gender

    doacoes.each do |data|
      validador  = validador.new(id, nova_data, data, gender)

      unless validador.confirma_doacao
        render json: {
          error: "Data inválida para doação"
        }
        return
      end
    end
    doacao.update(donation_date: nova_data)
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Doação não encontrada: #{e.message}" }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def deleta_agendamento
    begin
      ids = params[:ids]
      if ids.blank?
        render json: { error: "IDs ausentes" }, status: :bad_request
        return
      end

      Doacao.where(id: ids).destroy_all
      render json: { message: "Doações deletadas com sucesso." }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Doação não encontrada: #{e.message}" }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
