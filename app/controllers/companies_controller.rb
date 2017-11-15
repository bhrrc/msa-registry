class CompaniesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!, only: %i[update edit]

  def new
    @company = Company.new
    @company.statements.build
  end

  def create
    @company = Company.new(company_params)
    @company.associate_all_statements_with_user(current_user) if user_signed_in?
    if @company.save
      send_submission_email
      redirect_to thanks_path
    else
      # TODO: Fix rendering when there are errors
      render 'new'
    end
  end

  def show
    @company = Company.find(params[:id])
    @statements = @company.statements.order('date_seen DESC')
    @new_statement = Statement.new(company: @company)
    @statement = @company.latest_statement
  end

  private

  def send_submission_email
    email = @company.statements.reverse.map(&:contributor_email).compact.first
    StatementMailer.submitted(email).deliver_later if email.present?
  end

  def company_params
    params.require(:company).permit(COMPANY_ATTRIBUTES, statements_attributes: STATEMENTS_ATTRIBUTES)
  end

  COMPANY_ATTRIBUTES = %i[
    name
    country_id
    sector_id
  ].freeze

  STATEMENTS_ATTRIBUTES = %i[
    id
    url
    linked_from
    link_on_front_page
    approved_by
    approved_by_board
    signed_by
    signed_by_director
    published
    contributor_email
  ].freeze
end
