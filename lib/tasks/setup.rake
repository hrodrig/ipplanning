
namespace :app do
  desc "Setup defaults app settings"
  task :setup => :environment do

    Setting.find_or_create_by(name: 'DomainName').update_attributes(value: 'my.domain.name')
    Setting.find_or_create_by(name: 'WebsiteName').update_attributes(value: 'IP Planning')
    Setting.find_or_create_by(name: 'Brand').update_attributes(value: 'IPPLANNING')
    Setting.find_or_create_by(name: 'Footer').update_attributes(value: '&copy; 2017 - SAP friendly ip planning system')
    Setting.find_or_create_by(name: 'HeaderLeftImage').update_attributes(value: '')
    Setting.find_or_create_by(name: 'HeaderCentralTitle').update_attributes(value: '')
    Setting.find_or_create_by(name: 'HeaderRightImage').update_attributes(value: '')

  end
end
