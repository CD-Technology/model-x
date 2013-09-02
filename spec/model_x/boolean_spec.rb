require 'spec_helper'

module ModelX::Boolean
  class TestModel < ModelX::Base
  end
end

describe ModelX::Boolean do

  let(:model) { ModelX::Boolean::TestModel.new }
  before(:all) do
    ModelX::Boolean::TestModel.class_eval { attribute :archived, :type => :boolean }
  end

  specify { expect(model).to respond_to(:archived?) }
  specify { model.archived = true; expect(model.archived).to be_true }
  specify { model.archived = true; expect(model.archived?).to be_true }
  specify { model.archived = false; expect(model.archived).to be_false }
  specify { model.archived = false; expect(model.archived?).to be_false }

  specify { model.archived = '0'; expect(model.archived).to be_false }
  specify { model.archived = 0; expect(model.archived).to be_false }
  specify { model.archived = ''; expect(model.archived).to be_false }
  specify { model.archived = 'false'; expect(model.archived).to be_false }
  specify { model.archived = 'off'; expect(model.archived).to be_false }
  specify { model.archived = 'no'; expect(model.archived).to be_false }

  specify { model.archived = '1'; expect(model.archived).to be_true }
  specify { model.archived = 1; expect(model.archived).to be_true }
  specify { model.archived = '1'; expect(model.archived).to be_true }
  specify { model.archived = 'true'; expect(model.archived).to be_true }
  specify { model.archived = 'on'; expect(model.archived).to be_true }
  specify { model.archived = 'yes'; expect(model.archived).to be_true }
  specify { model.archived = 'something'; expect(model.archived).to be_true }

end