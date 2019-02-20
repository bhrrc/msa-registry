require 'rails_helper'

RSpec.describe Statement, type: :model do
  let :software do
    Industry.create! name: 'Software'
  end

  let :agriculture do
    Industry.create! name: 'Agriculture'
  end

  let :gb do
    Country.create! code: 'GB', name: 'United Kingdom'
  end

  let :no do
    Country.create! code: 'NO', name: 'Norway'
  end

  let :cucumber do
    Company.create! name: 'Cucumber Ltd', country: gb, industry: software
  end

  let :potato do
    Company.create! name: 'Potato Ltd', country: no, industry: agriculture
  end

  let! :cucumber_2016 do
    cucumber.statements.create!(
      url: 'http://cucumber.io/2016',
      approved_by: 'Aslak',
      approved_by_board: 'Yes',
      signed_by_director: false,
      link_on_front_page: true,
      date_seen: Date.parse('21 May 2016'),
      published: true,
      contributor_email: 'someone@somewhere.com'
    )
  end

  let! :cucumber_2017 do
    cucumber.statements.create!(
      url: 'http://cucumber.io/2017',
      approved_by: 'Aslak',
      approved_by_board: 'Yes',
      signed_by_director: false,
      link_on_front_page: true,
      date_seen: Date.parse('22 June 2017'),
      published: false,
      contributor_email: 'someone@somewhere.com'
    )
  end

  let! :potato_2016 do
    potato.statements.create!(
      url: 'http://potato.io/2016',
      approved_by: 'Aslak',
      approved_by_board: 'Yes',
      signed_by_director: 'No',
      link_on_front_page: true,
      date_seen: Date.parse('20 May 2016'),
      published: true,
      contributor_email: 'someone@somewhere.com'
    )
  end

  let! :potato_2017 do
    potato.statements.create!(
      url: 'http://potato.io/2017',
      approved_by: 'Aslak',
      approved_by_board: 'Yes',
      signed_by_director: 'No',
      link_on_front_page: true,
      date_seen: Date.parse('20 May 2017'),
      published: false,
      contributor_email: 'someone@somewhere.com'
    )
  end

  it 'groups the statements by company industry' do
    search = Statement.search(criteria: {})
    expect(search.industry_stats).to eq(
      [
        GroupCount.with(group: agriculture, count: 1),
        GroupCount.with(group: software, count: 1)
      ]
    )
  end

  it 'finds latest published statements ordered by company name' do
    search = Statement.search(criteria: {})
    expect(search.results).to eq([cucumber_2016, potato_2016])
  end

  it 'counts the statements' do
    expect(Statement.search(criteria: {}).stats).to eq(
      statements: 2,
      industries: 2,
      countries: 2
    )
    potato.update!(industry: software)
    expect(Statement.search(criteria: {}).stats).to eq(
      statements: 2,
      industries: 1,
      countries: 2
    )
    potato_2016.delete
    expect(Statement.search(criteria: {}).stats).to eq(
      statements: 1,
      industries: 1,
      countries: 1
    )
  end

  it 'filters statements by company name' do
    expect(
      Statement.search(criteria: { company_name: 'cucumber' }).results
    ).to eq([cucumber_2016])
  end

  it 'filters statements by countries' do
    expect(
      Statement.search(criteria: { countries: [gb.id, no.id] }).results
    ).to eq([cucumber_2016, potato_2016])
  end

  it 'filters statements by company industries' do
    expect(
      Statement.search(criteria: { industries: [agriculture.id, software.id] }).results
    ).to eq([cucumber_2016, potato_2016])
  end

  it 'handles queries containing punctuation' do
    expect(
      Statement.search(criteria: { company_name: 'cucumber &' }).results
    ).to eq([cucumber_2016])
  end
end
