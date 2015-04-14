# Encoding: UTF-8

require_relative '../spec_helper'

describe 'hipache::default' do
  let(:runner) { ChefSpec::ServerRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs Node.js' do
    expect(chef_run).to include_recipe('nodejs')
  end

  context 'a default version' do
    it 'installs the default version of Hipache' do
      expect(chef_run).to install_hipache_application('hipache')
        .with(version: 'latest')
    end
  end

  context 'an overridden version' do
    let(:runner) do
      ChefSpec::ServerRunner.new do |node|
        node.set['hipache']['version'] = '1.2.3'
      end
    end

    it 'installs Hipache with the overridden version' do
      expect(chef_run).to install_hipache_application('hipache')
        .with(version: '1.2.3')
    end
  end

  context 'a default config path' do
    it 'configures Hipache with the default config path' do
      expect(chef_run).to configure_hipache('hipache')
        .with(path: '/etc/hipache.json')
    end
  end

  context 'an overridden config path' do
    let(:runner) do
      ChefSpec::ServerRunner.new do |node|
        node.set['hipache']['config_path'] = '/tmp/test.json'
      end
    end

    it 'configures Hipache with the overridden config path' do
      expect(chef_run).to configure_hipache('hipache')
        .with(path: '/tmp/test.json')
    end
  end

  context 'a default config hash' do
    it 'configures Hipache with the default config hash' do
      expect(chef_run).to configure_hipache('hipache').with(config: nil)
    end
  end

  context 'an overridden config hash' do
    let(:override) { { 'server' => { 'access_log' => '/var/log/log.log' } } }
    let(:workers) { nil }
    let(:runner) do
      ChefSpec::ServerRunner.new do |node|
        node.set['hipache']['config_hash'] = override
        node.set['hipache']['workers'] = workers
      end
    end

    context 'no config conflicts' do
      it 'configures Hipache with the overridden config hash' do
        expect(chef_run).to configure_hipache('hipache')
          .with(config_hash: override)
      end
    end

    context 'a config conflict' do
      let(:workers) { 200 }

      it 'raises an error' do
        expect { chef_run }.to raise_error
      end
    end
  end

  opts = Hipache::Helpers::VALID_OPTIONS
  flattened = opts.select do |opt, _|
    ![:server, :https, :http].include?(opt)
  end
  flattened.merge(opts[:server].each_with_object({}) do |(k, v), res|
                    res[:"server_#{k}"] = v
                  end)
  flattened.merge(opts[:https].each_with_object({}) do |(k, v), res|
                    res[:"https_#{k}"] = v
                  end)
  flattened.merge(opts[:http].each_with_object({}) do |(k, v), res|
                    res[:"http_#{k}"] = v
                  end)
  flattened.each do |method, attrs|
    context "a default #{method}" do
      it "configures Hipache with the default #{method}" do
        expect(chef_run).to configure_hipache('hipache')
          .with(method => attrs[:default])
      end
    end

    context "an overridden #{method}" do
      let(:override) do
        case attrs[:kind_of].to_s
        when 'Fixnum'
          10_001
        when '[TrueClass, FalseClass]'
          false
        else
          'testables'
        end
      end
      let(:runner) do
        ChefSpec::ServerRunner.new do |node|
          if method.to_s.start_with?('https')
            node.set['hipache']['https'][method[6..-1].to_sym] = override
          elsif method.to_s.start_with?('http')
            node.set['hipache']['http'][method[5..-1].to_sym] = override
          elsif method.to_s.start_with?('server')
            node.set['hipache']['server'][method[7..-1].to_sym] = override
          else
            node.set['hipache'][method] = override
          end
        end
      end

      it "configure Hipache with the overridden #{method}" do
        expect(chef_run).to configure_hipache('hipache')
          .with(method => override)
      end
    end
  end

  it 'enables and starts the Hipache service' do
    expect(chef_run).to enable_hipache('hipache')
    expect(chef_run).to start_hipache('hipache')
  end
end
