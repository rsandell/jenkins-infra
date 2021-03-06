require 'spec_helper'

describe 'profile::kubernetes::resources::pluginsite' do
  let (:params) do
    {
        :url           => 'plugins.jenkins.io',
        :data_file_url => 'https://ci.jenkins.io/job/Infra/job/plugin-site-api/job/generate-data/lastSuccessfulBuild/artifact/plugins.json.gzip',
        :image_tag     => 'latest',
        :aliases       => []
    }
  end
  it { should contain_class('profile::kubernetes::params') }
  it { should contain_class('profile::kubernetes::kubectl') }
  it { should contain_class('profile::kubernetes::resources::lego') }
  it { should contain_class('profile::kubernetes::resources::nginx') }

  it { should contain_file("/home/k8s/resources/pluginsite").with(
    :ensure => 'directory',
    :owner  => 'k8s'
    )
  }
  it { should contain_profile__kubernetes__apply('pluginsite/service.yaml')}
  it { should contain_profile__kubernetes__apply('pluginsite/deployment.yaml').with(
    :parameters => {
      'image_tag' => 'latest'
      }
    )

  }
  it { should contain_profile__kubernetes__apply('pluginsite/configmap.yaml').with(
    :parameters => {
      'url'           => 'https://plugins.jenkins.io/api',
      'data_file_url' => 'https://ci.jenkins.io/job/Infra/job/plugin-site-api/job/generate-data/lastSuccessfulBuild/artifact/plugins.json.gzip'
      }
    )
  }
  it { should contain_profile__kubernetes__apply('pluginsite/ingress-tls.yaml').with(
    :parameters => {
      'url'     => 'plugins.jenkins.io',
      'aliases' => []
      }
    )
  }
  it { should contain_exec('Reload pluginsite pods')}
end
