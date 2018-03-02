require 'spec_helper'

describe 'appd_db_agent', type: :class do
  let :required_parameters do
    {
      source:  'https://example.com/dbagent-4.4.1.229.zip',
      version: '4.4.1.229',
      controller_host_name: 'exampleorg.saas.appdynamics.com',
      controller_port: 443,
      agent_account_access_key: 'secretsecret'
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        %w[source version controller_host_name controller_port agent_account_access_key].each do |param|
          it { is_expected.to compile.and_raise_error(%r{expects a value for parameter \'#{param}\'}) }
        end
      end

      context 'with all required parameters' do
        let :params do
          required_parameters
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('appd_db_agent') }
        it { is_expected.to contain_class('appd_db_agent::install') }
        it { is_expected.to contain_class('appd_db_agent::config').that_requires('Class[appd_db_agent::install]') }
        it { is_expected.to contain_class('appd_db_agent::service').that_subscribes_to('Class[appd_db_agent::config]') }
      end
    end
  end
end
