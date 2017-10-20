# ipplanning
IP Planning Easy !!

This is an application developed with Ruby on Rails to plan, manage and manage network segments, vlans, etc.

It has been developed to generate the contents of the / etc / hosts file that is used in * nix servers, very important in environments such as SAP, Oracle, etc., with high querying rates in name resolution and where it is unthinkable to implement a DNS.

Among the added functionalities it also allows to keep track of the assigned resources within virtualized environments or not, for the Production, Quality, Development, Solution Manager, etc. environments, in order to know the detail about the allocation of resources.

In distributed and heterogeneous environments where it is required to keep the contents of the hosts file synchronized, IPPlanning will simply make it easier for you every day !!

## How to install
- Clone this repo
- rake db:create
- rake db:migrate
- rake app:setup
- create Admin user inside rails console
- rails s
- enjoy !! :)

This application uses devise, but for security reasons we have left the management of the users only to be able to realize from inside the console of Rails.
