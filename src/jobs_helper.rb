#Scan and replace from string
require 'hound'
class Jobhelper

	def self.replace_symbols(string,target_machine)

		phone_endpoint = Hound.get_device_ip_from_type_and_machine(1,target_machine).first['ip']
		pad_endpoint = Hound.get_device_ip_from_type_and_machine(2,target_machine).first['ip']
		puts "Phone endpoint for target machine #{target_machine} is #{phone_endpoint} and Pad endpoint is #{pad_endpoint}"
		phone_serial = Hound.get_device_serial_from_type_and_machine(1,target_machine).first['serial_number']
		pad_serial = Hound.get_device_serial_from_type_and_machine(2,target_machine).first['serial_number']
		puts "Phone serial for target machine #{target_machine} is #{phone_serial} and Pad serial is #{pad_serial}#"

		if string.include?("$PAD_ENDPOINT")
			string.gsub!("$PAD_ENDPOINT",pad_endpoint)
		end
		if string.include?("$PHONE_ENDPOINT")
			string.gsub!("$PHONE_ENDPOINT",phone_endpoint)
		end
		if string.include?("$PHONE_SERIAL")
			string.gsub!("$PHONE_SERIAL",phone_serial)
		end
		if string.include?("$PAD_SERIAL")
		   string.gsub!("$PAD_SERIAL",pad_serial)
		end

		return string
	end

end
