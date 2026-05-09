require 'spec_helper'
require 'presenters/tonight'

RSpec.describe Presenters::Tonight do

  # define a sample schedule  
  let(:full_schedule) do
    {
      'Monday' => [{ 'name' => 'Show A' }],
      'Tuesday' => [{ 'name' => 'Show B' }]
    }
  end

  # mock the current day
  let(:today) { 'Monday' }

  # initialize a presenter
  let(:presenter) { described_class.new(full_schedule, today) }

  # 'happy path' to verify correct filter and select
  it 'filters the schedule to only show items for today' do
    result = presenter.to_h

    expect(result.size).to eq(1)
    expect(result.first['name']).to eq('Show A')
  end

  # 'empty state' to verify handling missing days 
  it 'returns an empty array if there are no shows for today' do
    wed_presenter = described_class.new(full_schedule, 'Wednesday')
    expect(wed_presenter.to_h).to eq([])
  end

end
