require 'spec_helper'

describe LocalePack::Pack do
  describe 'when initialized' do
    let(:pack_args) do
      attributes_for(:pack)
    end
    subject do
      described_class.new(pack_args)
    end
    it 'sets the locale pack attributes correctly' do
      expect(subject.name).to eq(pack_args[:name])
      expect(subject.digest).to eq(pack_args[:digest])
      expect(subject.file_name).to eq("#{pack_args[:name]}-#{pack_args[:digest]}.js")
    end
  end
end
