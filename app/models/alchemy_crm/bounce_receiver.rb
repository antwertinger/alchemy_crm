module AlchemyCrm

	class BounceReceiver < ActionMailer::Base

		def receive(email)
			return unless email.content_type == "multipart/report"
			logger.info "*** Bounced email received -- #{Time.now} ***"
			bounce = BouncedDelivery.from_email(email)
			recipient = AlchemyCrm::Recipient.find_by_message_id(bounce.original_message_id)
			recipient.bounced = (bounce.status == "Failure")
			recipient.save!
		end

	end

	class BouncedDelivery
		attr_accessor :status_info, :original_message_id 

		def self.from_email(email) 
			returning(bounce = self.new) do 
				status_part = email.parts.detect do |part| 
					part.content_type == "message/delivery-status" 
				end 
				statuses = status_part.body.split(/\n/)
				bounce.status_info = statuses.inject({}) do |hash, line| 
					key, value = line.split(/:/) 
					hash[key] = value.strip rescue nil 
					hash
				end 
				original_message_part = email.parts.detect do |part| 
					part.content_type == "message/rfc822"
				end 
				parsed_msg = Mail.parse(original_message_part.body) 
				bounce.original_message_id = parsed_msg.message_id
				end 
			end
		end

		def status
			case status_info['Status'] 
			when /^5/ 
				'Failure' 
			when /^4/ 
				'Temporary Failure' 
			when /^2/ 
				'Success' 
			end 
		end 

	end

end