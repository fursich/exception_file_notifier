require "spec_helper"
require "exception_test_helper"

RSpec.describe ExceptionNotifier::FileNotifier do
  include ExceptionTestHelper

  let(:notifier) {
    ExceptionNotifier::FileNotifier.new(
    options
    )
  }

  let(:options) {
    {
      filename:   filename,
      shift_age:  shift_age,
      shift_size: shift_size,
    }.compact
  }

  let(:filename)  { 'log/exceptions.log' }
  let(:shift_age) { 'daily' }
  let(:shift_size) { nil }


  it "has a version number" do
    expect(ExceptionFileNotifier::VERSION).not_to be nil
  end

  describe '#initialize' do
    let(:logger_options) {
      notifier.instance_eval {@logger_options}
    }
    it 'constructs the right file name based on given options' do
      expect(logger_options).to contain_exactly(filename, shift_age, shift_size)
    end
  end

  describe '#generate_json' do
    context 'in case broken strings are given' do
      let (:hash_with_broken_codes) {
        {
          French: 'La langue française'.force_encoding('ASCII'),
          Russian: 'Русский язык'.encode('WINDOWS-31J').force_encoding('UTF-16'),
          Japanese: {'日本語'.encode('UTF-8').force_encoding('WINDOWS-31J') => 'にほんご'.force_encoding('ASCII') },
        }
      }

      it 'jasonifies the strings properly without causing errors' do
        expect( JSON.parse(notifier.generate_json(hash_with_broken_codes)) ).to eq(
          {
            "French"=>"La langue fran\\xC3\\xA7aise",
            "Russian"=>"\\x84\\x51\\x84\\x85\\x84\\x83\\x84\\x83\\x84\\x7B\\x84\\x79\\x84\\x7A\\x20\\x84\\x91\\x84\\x78\\x84\\x8D\\x84\\x7B",
            "Japanese" => {"\\x{E697}\\xA5\\x{E69C}\\xAC\\x{E8AA}\\x9E"=>"\\xE3\\x81\\xAB\\xE3\\x81\\xBB\\xE3\\x82\\x93\\xE3\\x81\\x94"},
          }
        )
      end
    end
  end

  describe '#call' do
    let (:backtrace) {
      [
        %(/test/app/controllers/api/dummy_controller.rb:123:in `build_whatever_params'),
        %(/test/app/controllers/api/dummy_controller.rb:321:in `any_random_loop'),
      ]
    }

    context 'with env options' do
      let (:env) {
        { "rack.version"      => [1, 2],
          "action_controller.instance" => ExceptionTestHelper::DummyController.new,
          "REQUEST_METHOD"    => "GET",
          "SERVER_NAME"       => "example.org",
          "SERVER_PORT"       => "80",
          "PATH_INFO"         => "/category",
          "rack.url_scheme"   => "http",
          "REMOTE_ADDR"       => "127.0.0.1",
          "HTTP_HOST"         => "example.org",
        }
      }

      it 'indicates the exception' do
        expect(notifier).to receive(:append_log).with(
          hash_including(
            exception: ExceptionTestHelper::DummyException,
            exception_message: 'Dummy Exception Message'
          )
        ).once
        notifier.call(ExceptionTestHelper::DummyException.new(backtrace), env: env)
      end

      it 'provides controller and action name' do
        expect(notifier).to receive(:append_log).with(
          hash_including(
            controller: 'DummyController',
            action: 'TestAction'
          )
        ).once
        notifier.call(ExceptionTestHelper::DummyException.new(backtrace), env: env)
      end

      it 'provides url' do
        expect(notifier).to receive(:append_log).with(
          hash_including(
            url: "http://example.org/category"
          )
        ).once
        notifier.call(ExceptionTestHelper::DummyException.new(backtrace), env: env)
      end

      it 'provides backtrace' do
        expect(notifier).to receive(:append_log).with(
          hash_including(backtrace: backtrace)
        ).once
        notifier.call(ExceptionTestHelper::DummyException.new(backtrace), env: env)
      end
    end

    context 'without controller' do
      let (:env) {
        { "rack.version"      => [1, 2],
          "REQUEST_METHOD"    => "GET",
          "SERVER_NAME"       => "example.org",
          "SERVER_PORT"       => "80",
          "PATH_INFO"         => "/category",
          "rack.url_scheme"   => "http",
          "REMOTE_ADDR"       => "127.0.0.1",
          "HTTP_HOST"         => "example.org",
        }
      }
      it 'does not provide controller and action name' do
        expect(notifier).to receive(:append_log).with(
          hash_including(
            controller: '[BACKGROUND]',
            action: '[BACKGROUND]'
          )
        ).once
        notifier.call(ExceptionTestHelper::DummyException.new(backtrace), env: env)
      end
    end

    context 'without env options' do
      it 'indicates the exception' do
        expect(notifier).to receive(:append_log).with(
          hash_including(
            exception: ExceptionTestHelper::DummyException,
            exception_message: 'Dummy Exception Message'
          )
        )
        notifier.call(ExceptionTestHelper::DummyException.new)
      end

      it 'does not provide controller and action name' do
        expect(notifier).to receive(:append_log).with(
          hash_including(
            controller: '[BACKGROUND]',
            action: '[BACKGROUND]'
          )
        )
        notifier.call(ExceptionTestHelper::DummyException.new)
      end
    end
  end

end
