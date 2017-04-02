require 'spec_helper'

RSpec.describe Eql::Config do
  let(:conf) { described_class.new }

  it 'defaults' do
    expect(conf.adapter).to eq :active_record
    expect(conf.default_adapter).to eq Eql::Adapters::ActiveRecord
    expect(conf.path).to eq Dir.pwd
    expect(conf.cache_templates?).to eq true
  end

  context 'when Rails defined' do
    let(:rails) { double('Rails', root: 'foo') }

    it 'should user Rails.root' do
      stub_const('Rails', rails)
      expect(conf.path).to eq rails.root
    end
  end

  describe 'set options' do
    it 'should change default options' do
      conf.path = 'test'
      conf.adapter = :test_adapter
      conf.cache_templates = false
      expect(conf.path).to eq 'test'
      expect(conf.adapter).to eq :test_adapter
      expect(conf.cache_templates?).to eq false
    end
  end
end
