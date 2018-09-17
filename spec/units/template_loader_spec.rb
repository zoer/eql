require 'spec_helper'

RSpec.describe Eql::TemplateLoader do
  let(:builder) { Eql::Builder.new(path, conn) }
  let(:path) { File.expand_path('../../fixtures/active_record', __FILE__) }
  let(:conn) {}
  let(:loader) { described_class.new(builder) }

  describe '#resolve_path' do
    let(:adapter) { double(extension: '.{erb,sql.erb}') }

    before(:example) { allow(builder).to receive(:adapter) { adapter } }

    it "should resolve template's path" do
      expect(loader.resolve_path(:simple)).to eq \
        File.expand_path('../../fixtures/active_record/simple.sql.erb', __FILE__)
    end

    context "with multiple paths" do
      let(:path) do
        [
          File.expand_path('../../fixtures', __FILE__),
          File.expand_path('../../fixtures/active_record', __FILE__),
          File.expand_path('../..', __FILE__)
        ]
      end

      it "should resolve path correctly " do
        expect(loader.resolve_path(:simple)).to eq \
          File.expand_path('../../fixtures/active_record/simple.sql.erb', __FILE__)
      end
    end

    it "should raise an error if can find tempale's file" do
      expect { loader.resolve_path(:unexisted) }.to raise_error(/unable to find/i)
    end
  end

  describe '#load_template' do
    before(:example) do
      loader.class.cache.clear
      Eql.config.cache_templates = cache
    end

    context 'when cache is enabled' do
      let(:cache) { true }

      it 'should use cache' do
        expect(loader).to receive(:load_file).and_return(:foo).once
        expect { loader.load_template(:simple) }.to change { loader.cache.empty? }.to(false)
        expect { loader.load_template(:simple) }.to_not change { loader.cache.empty? }
        expect(loader.load_template(:simple)).to eq :foo
      end
    end

    context 'when cache is disabled' do
      let(:cache) { false }

      it 'should use cache' do
        expect(loader).to receive(:load_file).and_return(:foo).exactly(3).times
        expect { loader.load_template(:simple) }.to_not change { loader.cache.empty? }.from(true)
        expect { loader.load_template(:simple) }.to_not change { loader.cache.empty? }
        expect(loader.load_template(:simple)).to eq :foo
      end
    end
  end
end
