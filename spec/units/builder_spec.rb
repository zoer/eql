require 'spec_helper'

RSpec.describe Eql::Builder do
  let(:path) { File.expand_path('../../fixtures/active_record', __FILE__) }
  let(:conn) {}
  let(:builder) { described_class.new(path, conn) }

  before(:example) { Eql::TemplateLoader.cache.clear }

  describe '#load_template' do
    it 'should load template form a file' do
      builder.load_template(:simple)
      expect(builder.template_content.strip).to eq 'SELECT 1;'
    end

    it 'when there is no template with given name it should raise an error' do
      expect do
        builder.load_template(:unexisted)
      end.to raise_error(/unable to find/i)
    end
  end

  describe '#load_params' do
    let(:params) { { test: 1 } }

    it 'should load params' do
      builder.load_params(params)
      expect(builder.instance_variable_get(:@params)).to eq params
    end
  end

  describe '#template' do
    it 'should set raw template' do
      builder.template('SELECT 2;')
      expect(builder.template_content).to eq 'SELECT 2;'
    end
  end

  describe '#proxy_class' do
    before(:example) do
      expect(Eql::AdapterFactory).to receive(:factory) { Eql::Adapters::ActiveRecord }
      expect(Eql::Proxy).to \
        receive(:generate).with(Eql::Adapters::ActiveRecord).and_call_original
    end

    it 'should generate a proxy' do
      expect(builder.proxy_class.ancestors).to \
        include Eql::Adapters::ActiveRecord::ContextHelpers
    end
  end

  describe '#render' do
    let(:params) { { foo: "1'23" } }
    before(:example) do
      builder.template('SELECT <%= quote(foo) %>;')
      builder.load_params(params)
    end

    it 'should render a template' do
      expect(builder.render).to eq "SELECT '1''23';"
    end
  end

  describe '#adapter' do
    let(:conn) { double }

    before(:example) do
      expect(Eql::AdapterFactory).to \
        receive(:factory).with(conn) { Eql::Adapters::ActiveRecord }
    end

    it 'should load an adapter' do
      expect(builder.adapter).to be_a Eql::Adapters::ActiveRecord
      expect(builder.adapter.builder).to eq builder
    end
  end

  describe '#execute' do
    let(:tmpl) { :simple }
    let(:params) { { foo: 1 } }
    let(:adapter) { double(execute: 'results') }

    before(:example) do
      allow(builder).to receive(:adapter) { adapter }
    end

    it 'should call execute on adapter' do
      expect(builder).to receive(:load).with(tmpl, params).ordered
      expect(adapter).to receive(:execute).ordered
      expect(builder.execute(tmpl, params)).to eq adapter.execute
    end

    it 'should not raise and error w/o params' do
      expect(builder.execute).to eq adapter.execute
    end
  end

  describe '#execute' do
    let(:params) { { foo: 1 } }
    let(:adapter) { double(execute: 'results') }

    before(:example) do
      allow(builder).to receive(:adapter) { adapter }
    end

    it 'should call execute on adapter' do
      expect(builder).to receive(:load_params).with(params).ordered
      expect(adapter).to receive(:execute).ordered
      expect(builder.execute_params(params)).to eq adapter.execute
    end
  end

  describe '#clone' do
    let(:cloned) { builder.clone }
    let(:conn) { double }

    it 'should clone builder' do
      expect(cloned).to be_a Eql::Builder
      expect(cloned).to_not eq builder
      expect(cloned.path).to eq builder.path
      expect(cloned.conn).to eq builder.conn
    end
  end

  it '#builder' do
    expect(builder.loader).to be_a Eql::TemplateLoader
    expect(builder.loader.builder).to eq builder
  end

  it '#load_template' do
    expect(builder.loader).to receive(:load_template).with(:simple) { 'foo' }
    expect(builder.load_template(:simple)).to eq 'foo'
    expect(builder.template_content).to eq 'foo'
  end
end
