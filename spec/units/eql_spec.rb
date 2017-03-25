require 'spec_helper'

RSpec.describe Eql do
  let(:mod) { described_class }

  describe '.new' do
    let(:res) { mod.new }

    it 'should not raise errors without params' do
      b = mod.new
      expect(b).to be_a Eql::Builder
      expect(b.path).to eq Eql.config.path
    end

    it 'should pass params to a builder' do
      b = mod.new('foo', :conn)
      expect(b.path).to eq 'foo'
      expect(b.conn).to eq :conn
    end
  end

  it '.register_adapter' do
    mod.register_adapter(:klass, 'foo')
    expect(Eql::AdapterFactory.adapters[:klass]).to eq 'foo'
  end

  it '.configure' do
    mod.configure { |c| c.path = '/root/path/to/templates' }
    expect(Eql.config.path).to eq '/root/path/to/templates'
  end

  describe '.execute' do
    it 'should create a builder and execute it' do
      expect_any_instance_of(Eql::Builder).to receive(:load).with(:name, :params)
      expect_any_instance_of(Eql::Builder).to receive(:execute) { :result }
      expect(mod.execute(:name, :params)).to eq :result
    end
  end

  describe '.load' do
    it 'should create a builder' do
      expect_any_instance_of(Eql::Builder).to receive(:load).with(:name, :params)
      b = mod.load(:name, :params)
      expect(b).to be_a Eql::Builder
    end
  end

  describe '.template' do
    it 'should create a builder with a custom template' do
      expect_any_instance_of(Eql::Builder).to receive(:template).with('erb content')
      b = mod.template('erb content')
      expect(b).to be_a Eql::Builder
    end
  end
end
