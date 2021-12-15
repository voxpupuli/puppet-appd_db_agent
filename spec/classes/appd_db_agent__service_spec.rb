# frozen_string_literal: true

require 'spec_helper'

describe 'appd_db_agent', type: :class do
  let :required_parameters do
    {
      source: 'https://example.com/dbagent-4.4.1.229.zip',
      version: '4.4.1.229',
      controller_host_name: 'exampleorg.saas.appdynamics.com',
      controller_port: 443,
      agent_account_access_key: 'secretsecret'
    }
  end

  describe 'service' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with all required parameters' do
          let :params do
            required_parameters
          end

          it {
            expect(subject).to contain_service('appd_db_agent').with(
              'ensure' => 'running',
              'enable' => true
            )
          }
        end
      end
    end
  end
end
