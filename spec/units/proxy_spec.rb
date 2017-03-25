require 'spec_helper'

RSpec.describe Eql::Proxy do
  let(:klass) { described_class }

  describe '.generate' do
    let(:m1) { Module.new }
    let(:m2) { Module.new }
    let(:adapter) { Class.new }

    before(:example) do
      expect(Eql::AdapterFactory).to receive(:adapter_helpers) { [m1, m2] }.once
    end

    it 'should generate and cache a proxy class' do
      k = klass.generate(adapter)
      expect(k.include?(m1)).to eq true
      expect(k.include?(m2)).to eq true
      expect(klass.generate(adapter)).to eq k
      expect(k.ancestors).to include Eql::Proxy
    end
  end

  describe '.render' do
    let(:builder) { double('Builder') }
    let(:cloned) { double('Builder') }
    let(:proxy) { klass.new(builder, nil) }

    before(:example) do
      proxy.instance_variable_set(:@builder, builder)
    end

    it 'should clone builder and execute a paritial' do
      expect(builder).to receive(:clone) { cloned }
      expect(cloned).to receive(:load).with(:name, {x: 1})
      expect(cloned).to receive(:render)
      proxy.render(:name, x: 1)
    end
  end

  describe 'params delegation' do
    let(:builder) { double }
    let(:proxy) { klass.new(builder, params) }

    context 'when params is a hash' do
      let(:params) { { 'x' => 1 } }

      it 'should delegate params methods to a proxy' do
        expect(proxy.x).to eq params['x']
      end
    end

    context 'when params is a object' do
      let(:params) { double(x: 1) }

      it 'should delegate params methods to a proxy' do
        expect(proxy.x).to eq params.x
      end
    end

    context 'when params is nil' do
      let(:params) { nil }

      it 'should delegate params methods to a proxy' do
        expect { proxy.x }.to raise_error NoMethodError
      end
    end

    context 'when params is an array' do
      let(:params) { [1, 2] }

      it 'should delegate params methods to a proxy' do
        expect(proxy.first).to eq params.first
        expect(proxy[1]).to eq params.last
      end
    end
  end
end
