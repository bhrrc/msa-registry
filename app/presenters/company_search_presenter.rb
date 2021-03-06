class CompanySearchPresenter
  attr_reader :form, :service

  def initialize(form)
    @form = form
    @service = CompanySearchService.new(form)
  end

  def companies
    service.results
  end

  def stats
    service.stats
  end

  def searching_by_conditions?
    @service.searching_by_conditions?
  end

  def filtering_only_by_company_name?
    @service.filtering_only_by_company_name?
  end

  def modern_slavery_act?
    @service.modern_slavery_act?
  end

  def statement_count_for(company)
    return company.published_statements.count if @form.legislations.blank?

    company.published_statements.joins(:legislations).where(legislations: { id: @form.legislations }).count
  end
end
