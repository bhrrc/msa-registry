module Admin
  class StatementsController < AdminController
    before_action :find_company, only: %i[new create]

    def edit
      @statement = Statement.find(params[:id])
    end

    def update
      @statement = Statement.find(params[:id])
      if @statement.update(statement_params)
        @statement.associate_with_user(current_user)
        @statement.save!
        redirect_to admin_company_path(@statement.company)
      else
        render :edit
      end
    end

    def show
      @statement = Statement.find(params[:id])
    end

    def new
      @statement = @company.statements.build
    end

    def create
      @statement = @company.statements.build(statement_params)
      @statement.associate_with_user(current_user)

      if @statement.save
        redirect_to admin_company_path(@company)
      else
        render :new
      end
    end

    def snapshot
      @statement = Statement.find(params[:id])
      @statement.fetch_snapshot
      @statement.save!
      redirect_to admin_statement_path(@statement)
    end

    def destroy
      statement = Statement.find(params[:id])
      company = statement.company
      statement.destroy

      redirect_to admin_company_path(company)
    end

    def mark_url_not_broken
      @statement = Statement.find(params[:id])
      @statement.update!(broken_url: false, marked_not_broken_url: true)
      redirect_to admin_statement_path(@statement)
    end

    private

    def find_company
      @company = Company.find(params[:company_id])
    end

    def statement_params
      params.require(:statement).permit(STATEMENT_ATTRIBUTES)
    end

    STATEMENT_ATTRIBUTES = (%i[
      id
      url
      override_url
      linked_from
      link_on_front_page
      approved_by
      approved_by_board
      signed_by
      signed_by_director
      published
      contributor_email
    ] + [{ legislation_ids: [], year_covered: [], additional_companies_covered_ids: [] }]).freeze
  end
end
