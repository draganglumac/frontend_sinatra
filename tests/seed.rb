require 'rubygems'
require "pry"
require "sequel" 
require 'yaml'

class Seed

    def self.run()

        

        # =============
        # = platforms =
        # =============

        ios_id= DB[:platforms].insert :name => "ios"
        DB[:platforms].insert :name => "android"


        #device_types
        phone = DB[:device_types].insert :name => "phone"
        tablet = DB[:device_types].insert :name => "tablet"

        #manufactures
        apple = DB[:manufacturers].insert :name => "apple"
        samsung = DB[:manufacturers].insert :name  => "samsung"

        # ===========
        # = Devices =
        # ===========
        iphone_id = DB[:devices].insert :name  => "iphone4",:tag => "a001",  :serial_number => "apple001",:platform_id => ios_id,:device_type_id => phone,:manufacturer_id => apple
        tablet_id = DB[:devices].insert :name  => "ipad",:tag => "a002", :serial_number => "apple002",:platform_id => ios_id ,:device_type_id => tablet,:manufacturer_id => apple 

        # ============
        # = machines =
        # ============
        machine_id = DB[:machines].insert :call_sign => "goose",:ip_address => "172.20.160.147",:platform_id => ios_id,:port => "9099"
        DB[:machines].insert :call_sign => "maverick",:ip_address => "127.0.0.1",:platform_id => ios_id,:port => "9099"

        # =====================
        # = Connected Devices =
        # =====================
        DB[:connected_devices].insert :machine_id => machine_id,:device_id => iphone_id
        DB[:connected_devices].insert :machine_id => machine_id,:device_id => tablet_id

        # ========
        # = Jobs =
        # ========
        time_near_future = Time.now.to_i + 180

        DB[:jobs].insert :name => "hudsoniPhoneExample",:machine_id => machine_id,:command => "mkdir -p hudsoniphoneexample; cd hudsoniphoneexample; pwd; git clone git@github.com:AlexsJones/Hudson-Integration.git .; cd ../; rm -rf hudsoniphoneexample;",:status => "INCOMPLETE",:trigger_time => time_near_future.to_s

        puts "Seed done"
    end
end  



