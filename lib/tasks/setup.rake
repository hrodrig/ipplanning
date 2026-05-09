
namespace :app do
  desc "Setup defaults app settings"
  task :setup => :environment do

    Setting.find_or_create_by(name: 'DomainName').update(value: 'my.domain.name')
    Setting.find_or_create_by(name: 'WebsiteName').update(value: 'IP Planning')
    Setting.find_or_create_by(name: 'Brand').update(value: 'IPPLANNING')
    Setting.find_or_create_by(name: 'Footer').update(value: '&copy; 2017 - SAP friendly ip planning system')
    Setting.find_or_create_by(name: 'HeaderLeftImage').update(value: '')
    Setting.find_or_create_by(name: 'HeaderCentralTitle').update(value: '')
    Setting.find_or_create_by(name: 'HeaderRightImage').update(value: '')
    Setting.find_or_create_by(name: 'BasicAuthRequired').update(value: false)
    Setting.find_or_create_by(name: 'BasicAuthUsername').update(value: 'foo')
    Setting.find_or_create_by(name: 'BasicAuthPassword').update(value: 'bar')

  end
end
