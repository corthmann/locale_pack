require 'spec_helper'

describe LocalePack::PackFile do
  let(:pack_args) do
    attributes_for(:pack_file)
  end
  subject do
    described_class.new(pack_args)
  end

  describe 'when initialized' do
    it 'sets the locale pack attributes correctly' do
      expect(subject.name).to eq(File.basename(pack_args[:path], '.yml'))
      expect(subject.path).to eq(pack_args[:path])
    end
    it 'derives the file dependencies correctly' do
      pack_file_dependencies = %w(common.da.yml common.en.yml).map { |f| File.join(LocalePack.config.locale_path,f) }
      file_dependencies      = %w(example_a.da.yml example_a.en.yml).map { |f| File.join(LocalePack.config.locale_path,'a', f) }
      expect(subject.files).to eq(file_dependencies+pack_file_dependencies)
    end

    describe '#destroy' do
      it 'deletes the compiled locale pack from the file system' do
        subject.save
        expect { subject.destroy }.to change { subject.compiled? }.to be false
      end
    end

    describe '#pack' do
      it 'returns a "Pack" object that represents the "PackFile"' do
        expect(subject.pack).to eq(LocalePack::Pack.new(name: subject.name, digest: subject.digest))
      end
    end

    describe '#save' do
      after(:example) do
        subject.destroy
      end
      it 'compiles and saves the locale pack to the file system' do
        expect { subject.save }.to change { subject.compiled? }.to be true
      end
    end
  end

  describe '.find_all' do
    it 'returns a list of all pack files' do
      instances = described_class.find_all
      expect(instances).to be_an Array
      expect(instances.size).to eq(3)
      instances.each do |instance|
        expect(instance).to be_a described_class
      end
    end
  end

  describe '.find_by_name' do
    context 'given a valid pack file name' do
      it 'returns the pack file' do
        instance = described_class.find_by_name('example')
        expect(instance).to be_a described_class
        expect(instance.name).to eq('example')
      end
    end
  end
end
