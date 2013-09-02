require 'spec_helper'

module ModelX
  class TestModel < ModelX::Base
    attribute :status
  end
  class DerivedModel < TestModel
  end
end

describe ModelX::Attributes do

  let(:model) { ModelX::TestModel.new }

  context "trying to access a non-existent attribute" do
    specify { expect{ model.some_attribute = 'test' }.to raise_error(NoMethodError) }
    specify { expect{ model.some_attribute }.to raise_error(NoMethodError) }
    specify { expect(model[:some_attribute]).to be_nil }
  end

  context "trying to access an existent attribute" do
    specify { expect{ model.status = 'test' }.not_to raise_error }
    specify { expect{ model.status }.not_to raise_error }
    specify { model.status = 'test'; expect(model.status).to eql('test') }
    specify { model.status = 'test'; expect(model[:status]).to eql('test') }
  end

  it "should not allow an attribute to be defined more than once" do
    expect{ ModelX::TestModel.class_eval{ attribute :status } }.to raise_error(ModelX::AttributeAlreadyDefined)
  end

  describe '#attributes' do
    specify { expect(model.attributes).to eql(:status => nil) }
    context "with a value" do
      before { model.status = :one }
      specify { expect(model.attributes).to eql(:status => :one) }
    end

    it "should stay updated" do
      model.status = :one
      model.attributes
      model.status = :two
      expect(model.attributes).to eql(:status => :two)
    end
  end

  describe '#attributes=' do
    before { model.attributes = { :status => :one } }
    specify { expect(model.status).to be(:one) }
  end

  context "default value" do
    before(:all) do
      ModelX::TestModel.class_eval { attribute :type, :default => :post }
    end

    specify { expect(model.type).to be(:post) }
    specify { model.type = :attachment; expect(model.type).to be(:attachment) }
    specify { expect(ModelX::DerivedModel.new.type).to be(:post) }
  end

end