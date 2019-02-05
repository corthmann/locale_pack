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

    describe '#packs' do
      it 'returns a list of "Pack" objects that represents the "PackFile"' do
        expect(subject.packs).to be_an Array
        expect(subject.packs.size).to eq(LocalePack.config.export_locales.size + 1)
        # Verify that a pack exist for every locale.
        LocalePack.config.export_locales.each do |locale|
          expect(subject.packs.detect { |pack| pack.locale == locale }).to be
        end
        # Verify that each pack have valid attributes
        subject.packs.each do |pack|
          expect(pack.digest).to eq(subject.digest)
          expect(pack.locale).to satisfy { |locale| locale.nil? || LocalePack.config.export_locales.include?(locale) }
          if pack.locale
            expect(pack.id).to eq("#{subject.name}_#{pack.locale}")
            expect(pack.name).to eq(subject.name)
          else
            expect(pack.id).to eq(subject.name)
            expect(pack.name).to eq(subject.name)
          end
          expect(pack.file_name).to eq("#{pack.id}-#{pack.digest}.js")
        end
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
