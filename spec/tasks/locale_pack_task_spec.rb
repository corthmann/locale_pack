require 'spec_helper'
require 'rake'

describe 'locale_pack.rake' do
  before do
    Rake.application.rake_require "locale_pack/tasks/locale_pack"
    Rake::Task.define_task(:environment)
  end

  describe 'locale_pack:compile:one[name]' do
    context 'given a valid "name"' do
      let(:name) { 'example' }

      around(:example) do |example|
        example.run
        pack_file = LocalePack::PackFile.find_by_name(name.to_sym) rescue nil
        pack_file&.destroy
        LocalePack.manifest.delete
      end

      it 'compiles the PackFile with the given name' do
        expect(LocalePack::PackFile).to receive(:find_by_name).with(name.to_sym).and_call_original
        expect {
            Rake::Task["locale_pack:compile:one"].execute(Rake::TaskArguments.new([:name],[name]))
        }.to_not raise_error
      end
    end
  end
end
