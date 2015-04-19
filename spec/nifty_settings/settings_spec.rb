require 'spec_helper'

describe NiftySettings::Settings do
  let(:nested_settings_hash) { { pelle: 'fant', shnoo: 'shnaa' } }
  let(:settings_hash)        { { foo: 'bar', nested: nested_settings_hash, really?: true, not_really?: false, nothing?: nil } }
  let(:settings)             { NiftySettings::Settings.new(settings_hash) }
  let(:empty_settings)       { NiftySettings::Settings.new }

  context 'comparing two settings' do
    it 'works as expected' do
      expect(NiftySettings::Settings.new(settings_hash)).to     be == NiftySettings::Settings.new(settings_hash)
      expect(NiftySettings::Settings.new(settings_hash)).to_not be == NiftySettings::Settings.new(nested_settings_hash)
      expect(NiftySettings::Settings.new(settings_hash)).to_not be == 'random string'
    end
  end

  context '#key' do
    context 'when no setting with that key exists' do
      it 'returns nil' do
        expect(settings.not_found).to be_nil
      end

      it 'does not change the settings' do
        expect { settings.not_found }.to_not change { settings.to_h }
      end
    end

    context 'when the settings has a single value' do
      it 'returns the value' do
        expect(settings.foo).to eq('bar')
      end
    end

    context 'when the setting has nested values' do
      it 'returns a settings object with the values' do
        expect(settings.nested).to eq(NiftySettings::Settings.new(nested_settings_hash))
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

  describe '#key?' do
    context 'when no setting with that key exists' do
      it 'returns false' do
        expect(settings.bar?).to eq(false)
      end
    end

    context 'when the settings has a single value' do
      it 'returns true' do
        expect(settings.foo?).to eq(true)
      end
    end

    context 'when the settings has key ending with ?' do
      it 'returns true' do
        expect(settings.really?).to eq(true)
      end

      it 'returns false' do
        expect(settings.not_really?).to eq(false)
      end

      it 'returns nil' do
        expect(settings.nothing?).to be_nil
      end
    end

    context 'when the setting has nested values' do
      it 'returns true' do
        expect(settings.nested?).to eq(true)
      end
    end
  end

  describe '.load' do
    context 'without Rails and RACK_ENV' do
      before do
        # Make sure `ENV['RACK_ENV']` is not set and Rails is not loaded
        # so that the loaded settings are not scoped to the env.
        ENV['RACK_ENV'] = nil
        raise 'Rails should not be loaded.' if defined?(Rails)

        FileUtils.mkdir_p settings_dir
      end

      after do
        Dir[File.join(settings_dir, '*.yml')].unshift(settings_file).each do |file|
          File.delete file if File.exist?(file)
        end
        %i(settings_file settings_dir).each do |config|
          NiftySettings.configuration.unset config
        end
      end

      let(:settings_file) { File.expand_path('../../../config/settings.yml', __FILE__) }
      let(:settings_dir)  { File.expand_path('../../../config/settings', __FILE__) }
      1.upto(3).each do |i|
        let(:"support_settings_file_#{i}") { File.expand_path("../../support/settings#{i}.yml", __FILE__) }
      end

      context 'when only the settings file exists' do
        context 'in the default location' do
          before do
            FileUtils.cp support_settings_file_1, settings_file
          end

          it 'loads the settings' do
            settings = NiftySettings::Settings.load
            expect(settings).to eq('foo' => 'bar')
          end
        end

        context 'in a custom location' do
          before do
            NiftySettings.configuration.settings_file = support_settings_file_1
          end

          it 'loads the settings' do
            settings = NiftySettings::Settings.load
            expect(settings).to eq('foo' => 'bar')
          end
        end
      end

      context 'when only a file in the settings dir exists' do
        before do
          FileUtils.cp support_settings_file_1, settings_dir
        end

        it 'loads the settings' do
          settings = NiftySettings::Settings.load
          expect(settings).to eq('foo' => 'bar')
        end
      end

      context 'when the settings file and files in the settings dir exist' do
        before do
          FileUtils.cp support_settings_file_1, settings_file
          FileUtils.cp support_settings_file_2, settings_dir
          FileUtils.cp support_settings_file_3, settings_dir
        end

        it 'loads the settings' do
          settings = NiftySettings::Settings.load
          expect(settings).to eq(
            'foo'   => 'bar',
            'pelle' => 'fant',
            'zing'  => 'zang'
          )
        end
      end
    end
  end
end
