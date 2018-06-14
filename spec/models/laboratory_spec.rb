require 'rails_helper'

RSpec.describe Laboratory, type: :model do
  let(:laboratory) { build(:laboratory) } # chama o Factory Girl para criar uma laboratory com dados faker

  context 'When is new' do
    it { expect(laboratory).not_to be_done } # "be_" usado para campos booleanos.
  end

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :user_id }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:deadline) }
  it { is_expected.to respond_to(:done) }
  it { is_expected.to respond_to(:user_id) }
end