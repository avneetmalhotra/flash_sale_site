require "rails_helper"

RSpec.describe Image, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:deal) }
  end

  it { is_expected.to have_attached_file(:avatar) }
 
  describe 'validations' do
    context 'avatar' do
      it { is_expected.to validate_attachment_presence(:avatar) }
      it { is_expected.to validate_attachment_content_type(:avatar).allowing(PAPERCLIP_VALID_CONTENT_TYPES) }
      it { is_expected.to validate_attachment_size(:avatar).less_than(5.megabytes) }
    end
  end
end
