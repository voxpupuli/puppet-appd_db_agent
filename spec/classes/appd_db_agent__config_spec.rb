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

  let :params do
    required_parameters
  end

  describe 'config' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with all required parameters' do
          it {
            expect(subject).to contain_file('/etc/sysconfig/appd_db_agent').with(
              'ensure' => 'file',
              'owner' => 'root',
              'group' => 'root',
              'mode' => '0600'
            )
          }

          it { is_expected.to contain_systemd__unit_file('appd_db_agent.service') }
        end

        describe '/etc/sysconfig/appd_db_agent content' do
          context 'with all required parameters' do
            it {
              expect(subject).to contain_file('/etc/sysconfig/appd_db_agent').
                with_content(%r{^APPDYNAMICS_CONTROLLER_HOST_NAME=exampleorg\.saas\.appdynamics\.com$}).
                with_content(%r{^APPDYNAMICS_CONTROLLER_PORT=443$}).
                with_content(%r{^APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=secretsecret$}).
                without_content(%r{APPDYNAMICS_AGENT_ACCOUNT_NAME}).
                without_content(%r{APPDYNAMICS_CONTROLLER_SSL_ENABLED})
            }
          end

          context 'with agent_account_name set' do
            let :params do
              required_parameters.merge(agent_account_name: 'someaccountname')
            end

            it {
              expect(subject).to contain_file('/etc/sysconfig/appd_db_agent').
                with_content(%r{^APPDYNAMICS_AGENT_ACCOUNT_NAME=someaccountname$})
            }
          end

          describe 'controller_ssl_enabled' do
            context 'when set to true' do
              let :params do
                required_parameters.merge(controller_ssl_enabled: true)
              end

              it {
                expect(subject).to contain_file('/etc/sysconfig/appd_db_agent').
                  with_content(%r{^APPDYNAMICS_CONTROLLER_SSL_ENABLED=true$})
              }
            end

            context 'when set to false' do
              let :params do
                required_parameters.merge(controller_ssl_enabled: false)
              end

              it {
                expect(subject).to contain_file('/etc/sysconfig/appd_db_agent').
                  with_content(%r{^APPDYNAMICS_CONTROLLER_SSL_ENABLED=false$})
              }
            end
          end
        end

        describe 'systemd appd_db_agent.service unit content' do
          describe 'user parameter' do
            context 'when default' do
              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^User=appdynamics$})
              }
            end

            context 'when set' do
              let :params do
                required_parameters.merge(user: 'someuser')
              end

              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^User=someuser$})
              }
            end
          end

          describe 'java_home parameter' do
            context 'when default' do
              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/usr/lib/jvm/java/jre/bin/java })
              }
            end

            context 'when set' do
              let :params do
                required_parameters.merge(java_home: '/path/to/javahome')
              end

              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/path/to/javahome/jre/bin/java })
              }
            end
          end

          describe 'java_opts' do
            context 'by default' do
              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/usr/lib/jvm/java/jre/bin/java -Xms256m -Xmx256m -jar /opt/appdynamics/dbagent/db-agent\.jar -XX:\+ExitOnOutOfMemoryError})
              }
            end

            context 'with proxy options set' do
              let :params do
                required_parameters.merge(
                  proxy_host: 'squid.example.com',
                  proxy_port: 3128
                )
              end

              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/usr/lib/jvm/java/jre/bin/java -Dappdynamics\.http\.proxyHost=squid\.example\.com -Dappdynamics\.http\.proxyPort=3128 -Xms256m -Xmx256m -jar /opt/appdynamics/dbagent/db-agent\.jar -XX:\+ExitOnOutOfMemoryError})
              }
            end

            context 'with db_agent_name set' do
              let :params do
                required_parameters.merge(
                  db_agent_name: 'someagentname'
                )
              end

              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/usr/lib/jvm/java/jre/bin/java -Ddbagent\.name=someagentname -Xms256m -Xmx256m -jar /opt/appdynamics/dbagent/db-agent\.jar -XX:\+ExitOnOutOfMemoryError})
              }
            end

            context 'with java_heap_size set' do
              let :params do
                required_parameters.merge(
                  java_heap_size: '1G'
                )
              end

              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/usr/lib/jvm/java/jre/bin/java -Xms1G -Xmx1G -jar /opt/appdynamics/dbagent/db-agent\.jar -XX:\+ExitOnOutOfMemoryError})
              }
            end

            context 'with all parameters set' do
              let :params do
                required_parameters.merge(
                  proxy_host: 'squid.example.com',
                  proxy_port: 3128,
                  db_agent_name: 'someagentname',
                  java_heap_size: '1G'
                )
              end

              it {
                expect(subject).to contain_systemd__unit_file('appd_db_agent.service').
                  with_content(%r{^ExecStart=/usr/lib/jvm/java/jre/bin/java -Dappdynamics\.http\.proxyHost=squid\.example\.com -Dappdynamics\.http\.proxyPort=3128 -Ddbagent\.name=someagentname -Xms1G -Xmx1G -jar /opt/appdynamics/dbagent/db-agent\.jar -XX:\+ExitOnOutOfMemoryError})
              }
            end
          end
        end
      end
    end
  end
end
