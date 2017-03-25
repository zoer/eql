require 'spec_helper'

RSpec.describe 'parital rendering' do
  let(:path) { File.expand_path('../../fixtures/active_record', __FILE__) }
  let(:conn) {}
  let(:builder) { Eql::Builder.new(path, conn) }

  it 'should render partial template' do
    arr = [1, 2, 3]
    res = builder.execute(:complex, arr.dup)
    expect(res.size).to eq arr.size
    arr.each_with_index do |num, idx|
      expect(res[idx]).to include('num' => num)
    end
  end
end
