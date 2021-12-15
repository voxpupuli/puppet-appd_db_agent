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

  describe 'install' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with all required parameters' do
          let :params do
            required_parameters
          end

          it { is_expected.to contain_class('appd_db_agent::install') }
          it { is_expected.to contain_group('appdynamics').with_ensure('present') }

          it {
            expect(subject).to contain_user('appdynamics').with(
              'ensure' => 'present',
              'gid' => 'appdynamics',
              'home' => '/opt/appdynamics',
              'managehome' => false,
              'shell' => '/sbin/nologin',
              'system' => true
            )
          }

          it {
            expect(subject).to contain_file('/opt/appdynamics').with(
              'ensure' => 'directory',
              'owner' => 'appdynamics',
              'group' => 'appdynamics',
              'mode' => '0640'
            )
          }

          it {
            expect(subject).to contain_file('/opt/appdynamics/dbagent-4.4.1.229').with(
              'ensure' => 'directory',
              'owner' => 'appdynamics',
              'group' => 'appdynamics',
              'mode' => '0640'
            )
          }

          it {
            expect(subject).to contain_archive('/tmp/dbagent-4.4.1.229.zip').with(
              'ensure' => 'present',
              'source' => 'https://example.com/dbagent-4.4.1.229.zip',
              'extract' => true,
              'extract_path' => '/opt/appdynamics/dbagent-4.4.1.229',
              'creates' => '/opt/appdynamics/dbagent-4.4.1.229/db-agent.jar',
              'cleanup' => true,
              'user' => 'appdynamics',
              'group' => 'appdynamics'
            ).that_requires('File[/opt/appdynamics/dbagent-4.4.1.229]')
          }

          it {
            expect(subject).to contain_file('/opt/appdynamics/dbagent').with(
              'ensure' => 'link',
              'owner' => 'appdynamics',
              'group' => 'appdynamics',
              'target' => '/opt/appdynamics/dbagent-4.4.1.229',
              'mode' => '0640'
            )
          }
        end

        context 'with user parameter set' do
          let :params do
            required_parameters.merge(
              user: 'someuser'
            )
          end

          it { is_expected.to contain_user('someuser') }
          it { is_expected.to contain_file('/opt/appdynamics').with_owner('someuser') }
          it { is_expected.to contain_file('/opt/appdynamics/dbagent-4.4.1.229').with_owner('someuser') }
          it { is_expected.to contain_file('/opt/appdynamics/dbagent').with_owner('someuser') }
          it { is_expected.to contain_archive('/tmp/dbagent-4.4.1.229.zip').with_user('someuser') }
        end

        context 'with group parameter set' do
          let :params do
            required_parameters.merge(
              group: 'somegroup'
            )
          end

          it { is_expected.to contain_group('somegroup') }
          it { is_expected.to contain_user('appdynamics').with_gid('somegroup') }
          it { is_expected.to contain_file('/opt/appdynamics').with_group('somegroup') }
          it { is_expected.to contain_file('/opt/appdynamics/dbagent-4.4.1.229').with_group('somegroup') }
          it { is_expected.to contain_file('/opt/appdynamics/dbagent').with_group('somegroup') }
          it { is_expected.to contain_archive('/tmp/dbagent-4.4.1.229.zip').with_group('somegroup') }
        end

        context 'with manage_user set to false' do
          let :params do
            required_parameters.merge(
              manage_user: false
            )
          end

          it { is_expected.to have_user_resource_count(0) }
          it { is_expected.to have_group_resource_count(0) }
        end
      end
    end
  end
end
