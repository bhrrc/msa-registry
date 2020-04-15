class ExploreController < ApplicationController
  include ApplicationHelper

  def index
    respond_to do |format|
      format.html do
        @download_url = build_csv_url
        @search = search
        @results = search.companies
      end
      format.csv do
        send_csv
      end
    end
  end

  private

  def build_csv_url
    explore_path(params
      .to_unsafe_hash.merge(format: 'csv'))
  end

  def search
    form = CompanySearchForm.new(criteria_params)
    CompanySearchPresenter.new(form)
  end

  def send_csv
    send_data ResultsExporter.to_csv(search.companies, admin?, criteria_params), filename: csv_filename
  end

  def criteria_params
    {
      industries: params[:industries],
      countries: params[:countries],
      company_name: params[:company_name],
      legislations: params[:legislations],
      statement_keywords: params[:statement_keywords],
      include_keywords: params[:include_keywords],
      page: params[:page]
    }
  end

  def csv_filename
    "modernslaveryregistry-#{Time.zone.today}.csv"
  end
end
