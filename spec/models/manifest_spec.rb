require 'spec_helper'

describe LocalePack::Manifest do
  subject do
    described_class.new
  end

  describe 'when initialized' do
    it 'starts out empty' do
      expect(subject.packs).to be_empty
    end

    context 'given a pack was added' do
      it 'the public is not empty' do
        expect { subject.add(build(:pack)) }.to change { subject.packs.size }.by(1)
      end
    end
  end

  describe '#load!' do
    around(:example) do |example|
      load_manifest = described_class.new
      load_manifest.add(build(:pack))
      load_manifest.save
      example.run
      load_manifest.delete
    end

    it 'loads the public from the file system' do
      expect { subject.load! }.to change { subject.packs.size }.by_at_least(1)
    end
  end

  describe '#save' do
    after(:example) do
      subject.delete
    end
    it 'saves the public as a file on the system' do
      subject.add(build(:pack))
      expect(subject.save).to be true
    end
  end

  describe '#delete' do
    it 'deletes the public file from the system' do
      # Build public and save it to the system
      subject.add(build(:pack))
      subject.save
      # Expect it to remove the public from the system.
      expect(subject.delete).to be true
      expect(subject.packs.size).to eq(0)
    end
  end
end
