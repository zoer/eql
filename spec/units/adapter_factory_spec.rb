require 'spec_helper'

RSpec.describe Eql::AdapterFactory do
  let(:klass) { described_class }

  it '.register_adapter' do
    klass.register_adapter(:klass, 'foo')
    expect(Eql::AdapterFactory.adapters[:klass]).to eq 'foo'
  end

  describe '.adapter_helpers' do
    let(:builder) { double }
    let(:adapter) { Eql::Adapters::ActiveRecord.new(builder) }

    it "should find adapter's helpers" do
      expect(klass.adapter_helpers(adapter)).to eq [
        Eql::Adapters::Base::ContextHelpers,
        Eql::Adapters::ActiveRecord::ContextHelpers,
      ]
    end
  end

  describe '.factory' do
    let(:default_adapter) { double }

    context 'when conn is nil' do
      before(:example) do
        expect(Eql.config).to receive(:default_adapter) { default_adapter }
      end

      it 'should take default adapter' do
        expect(klass.factory(nil)).to eq default_adapter
      end
    end

    it "should raise an error when can't find a class" do
      expect { klass.factory(:foo) }.to raise_error(/Unable to detect/)
    end

    it 'should find an adapter class' do
      expect(Eql::Adapters::ActiveRecord).to receive(:match?).with(:foo) { true }
      expect(klass.factory(:foo)).to eq Eql::Adapters::ActiveRecord
    end
  end
end
