require 'spec_helper'

describe ModelX::Percentage do

  let(:klass) do
    Class.new(ModelX::Base) do
      def self.name
        'PercentageExample'
      end

      attr_accessor :discount
      percentage :discount

      attr_reader :other
      percentage :other
    end
  end
  let(:object) { klass.new }

  it "should add a _percentage reader and writer" do
    expect(object).to respond_to(:discount_percentage)
    expect(object).to respond_to(:discount_percentage=)
  end

  it "should not add a writer on an object that doesn't have an existing writer" do
    expect(object).to_not respond_to(:other_percentage=)
  end

  describe "percentage writer" do

    it "should set the value / 100" do
      object.discount_percentage = 80
      expect(object.discount).to eql(0.8)
    end

    it "should set any non-present value to nil" do
      object.discount_percentage = false
      expect(object.discount).to be_nil

      object.discount_percentage = nil
      expect(object.discount).to be_nil

      object.discount_percentage = ''
      expect(object.discount).to be_nil
    end

  end

  describe 'validation' do

    it "should accept any number" do
      object.discount_percentage = 10
      expect(object).to be_valid
      object.discount_percentage = 110
      expect(object).to be_valid
      object.discount_percentage = -10
      expect(object).to be_valid
    end

    it "should not accept anything else" do
      object.discount_percentage = 'abcd'
      expect(object).to_not be_valid
      expect(object.errors[:discount_percentage]).to_not be_nil
    end

    it "should allow blank values" do
      object.discount_percentage = ''
      expect(object).to be_valid
    end

  end

  describe "percentage reader" do

    it "should report the value * 100" do
      object.discount = 0.5
      expect(object.discount_percentage).to eql(50.0)
    end

    it "should report nil upon any non-present attribute value" do
      object.discount = false
      expect(object.discount_percentage).to be_nil

      object.discount = nil
      expect(object.discount_percentage).to be_nil

      object.discount = ''
      expect(object.discount_percentage).to be_nil
    end

  end

  describe "#human_attribute_name override" do

    it "should translate the name of the attribute without _percentage" do
      expect(klass.human_attribute_name(:discount_percentage)).to eql(klass.human_attribute_name(:discount))
    end

  end


end