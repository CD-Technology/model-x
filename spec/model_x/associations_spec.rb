require 'spec_helper'

# Define this class top-level, because it will be accessed as a constant.
class ModelXTestRecord
  attr_reader :id
  def initialize(id)
    @id = id
  end
end

describe ModelX::Associations do

  let(:model_x_test_model_class) do
    Class.new(ModelX::Base) do
      belongs_to :model_x_test_record
    end
  end

  let(:model) { model_x_test_model_class.new }
  let(:records) { [ ModelXTestRecord.new(0), ModelXTestRecord.new(1) ] }

  before do
    allow(ModelXTestRecord).to receive(:find_by_id) { |id| records[id] }
  end

  context "trying to access a non-existent association" do
    specify { expect{ model.something }.to raise_error(NoMethodError) }
    specify { expect{ model.something_id }.to raise_error(NoMethodError) }
  end

  context "trying to access an existent association" do
    specify { expect{ model.model_x_test_record }.not_to raise_error }
    specify { expect{ model.model_x_test_record_id }.not_to raise_error }
  end

  context 'foreign key' do
    context "specifying nil" do
      before { model.model_x_test_record_id = nil }
      specify { expect(model.model_x_test_record_id).to be_nil }
    end
    context "specifying a non-existing ID" do
      before { model.model_x_test_record_id = 2 }
      specify { expect(model.model_x_test_record_id).to eql(2) }
    end
    context "specifying an existing ID" do
      before { model.model_x_test_record_id = 1 }
      specify { expect(model.model_x_test_record_id).to eql(1) }
    end
    context "specifying a related object" do
      before { model.model_x_test_record = records[0] }
      specify { expect(model.model_x_test_record_id).to eql(0) }
    end
  end

  context 'association' do
    context "without an ID" do
      specify { expect(model.model_x_test_record).to be_nil }
    end
    context "with a nonexisting ID" do
      before { model.model_x_test_record_id = 2 }
      specify { expect(model.model_x_test_record).to be_nil }
    end
    context "with an existing ID" do
      before { model.model_x_test_record_id = 1 }
      specify { expect(model.model_x_test_record).to be(records[1]) }
    end
    context "with an existing object" do
      before { model.model_x_test_record = records[1] }
      specify { expect(model.model_x_test_record).to be(records[1]) }
    end

    it "should convert to nil if any blank value is passed" do
      model.model_x_test_record = ""
      expect(model.model_x_test_record).to be_nil
    end

    it "should invalidate a cached record if the id changes" do
      model.model_x_test_record = records[1]
      model.model_x_test_record_id = 0
      expect(model.model_x_test_record).to be(records[0])
    end

    it "should honour a reload parameter" do
      model.model_x_test_record = records[1]
      model.instance_variable_set '@model_x_test_record_id', 0

      expect(model.model_x_test_record).to be(records[1])
      expect(model.model_x_test_record(true)).to be(records[0])
    end
  end

  describe "option overrides" do
    context "with another foreign key" do
      before do
        class ::ModelXTestRecord2; end

        allow(ModelXTestRecord2).to receive(:find_by_id) { ModelXTestRecord2.new }
        model_x_test_model_class.class_eval { belongs_to :model_x_test_record2, :foreign_key => :related_object_id }
      end

      specify { expect(model).to respond_to(:model_x_test_record2) }
      specify { expect(model).to respond_to(:model_x_test_record2=) }
      specify { expect(model).to_not respond_to(:model_x_test_record2_id) }
      specify { expect(model).to_not respond_to(:model_x_test_record2_id=) }
      specify { expect(model).to respond_to(:related_object_id) }
      specify { expect(model).to respond_to(:related_object_id=) }

      it "should use the corresponding foreign key" do
        expect(ModelXTestRecord2).to receive(:find_by_id).with(1)
        model.related_object_id = 1
        model.model_x_test_record2
      end
      it "should use the corresponding association name" do
        related_object = ModelXTestRecord2.new
        expect(related_object).to receive(:id).and_return(5)
        model.model_x_test_record2 = related_object
        expect(model.related_object_id).to eql(5)
      end
    end

    context "with another class name" do
      it "should use the correct class" do
        expect(ModelXTestRecord).to receive(:find_by_id).with(1)
        model_x_test_model_class.class_eval { belongs_to :again_model_x_test_record, :class_name => 'ModelXTestRecord' }
        model.again_model_x_test_record_id = 1
        model.again_model_x_test_record
      end
    end

  end

  # TODO: has_many

end