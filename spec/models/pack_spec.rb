require 'spec_helper'

describe LocalePack::Pack do
  let(:manifest) do
    m = LocalePack::Manifest.new
    m.add(build(:pack))
    m.add(build(:pack, name: 'pack_2'))
    m
  end

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
      expect(subject.locale).to be_nil
    end

    context 'with locale information' do
      let(:pack_args) { attributes_for(:pack_with_locale) }

      it 'sets the locale pack attributes correctly' do
        expect(subject.id).to eq("#{pack_args[:name]}_#{pack_args[:locale]}")
        expect(subject.name).to eq(pack_args[:name])
        expect(subject.digest).to eq(pack_args[:digest])
        expect(subject.locale).to eq(pack_args[:locale])
        expect(subject.file_name).to eq("#{pack_args[:name]}_#{pack_args[:locale]}-#{pack_args[:digest]}.js")
      end
    end
  end

  describe '.find_all' do
    it 'returns a list of Packs' do
      allow(LocalePack).to receive(:manifest).and_return(manifest)
      packs = described_class.find_all
      expect(packs).to be_an Array
      expect(packs.size).to eq(2)
      packs.each do |pack|
        expect(pack).to be_a described_class
      end
    end
  end

  describe '.find_by_name' do
    before(:example) do
      allow(LocalePack).to receive(:manifest).and_return(manifest)
    end

    context 'given the name of an existing pack' do
      it 'returns the correct pack' do
        pack = described_class.find_by_name('test')
        expect(pack).to be_a LocalePack::Pack
        expect(pack.name).to eq('test')
      end
    end

    context 'given a name that does not match any packs' do
      it 'raises an ArgumentError' do
        expect { described_class.find_by_name('invalid') }.
            to raise_error(ArgumentError, "Locale Pack 'invalid' not found")
      end
    end
  end


  describe '#==' do
    context 'given two identical packs' do
      it 'returns true' do
        expect(build(:pack) == build(:pack)).to be true
        expect(build(:pack_with_locale) == build(:pack_with_locale)).to be true
      end
    end

    context 'given two different packs' do
      it 'returns false' do
        expect(subject == build(:pack, name: 'other')).to be false
        expect(build(:pack_with_locale) == build(:pack_with_locale, locale: :en)).to be false
      end
    end
  end
end
