require 'spec_helper'

describe NiftySettings::Settings do
  let(:settings_hash)  { { foo: 'bar' } }
  let(:settings)       { NiftySettings::Settings.new(settings_hash) }
  let(:empty_settings) { NiftySettings::Settings.new }

  context 'accessing a setting' do
    context "when it's not present" do
      it 'returns nil' do
        expect(settings.not_found).to be_nil
      end
    end

    context "when it's present" do
      it 'returns the setting' do
        expect(settings.foo).to eq('bar')
      end
    end
  end

  describe '#to_s' do
    context 'when no settings are stored' do
      it 'returns an empty string' do
        expect(empty_settings.to_s).to eq('')
      end
    end

    context 'when settings are stored' do
      it 'returns a string representation of the settings' do
        expect(settings.to_s).to eq(settings_hash.to_s)
      end
    end
  end
end
