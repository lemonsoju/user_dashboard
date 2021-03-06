class User < ActiveRecord::Base
	has_many :messages
	has_many :comments, through: :messages

	attr_accessor :password, :password_confirmation

	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
	validates	:first_name,	:presence 	=> true,
				:length						=> {in: 2..30}

	validates	:last_name, 	:presence	=> true,
				:length						=> {in: 2..30}

	validates	:email, 		:presence	=> true,
				:format						=> {with: EMAIL_REGEX}

	validates	:email,			:uniqueness	=> {case_sensitive: false},
				:unless 					=> :already_has_email?

	validates	:password, 		:presence	=> true,
				:confirmation				=> true,
				:length						=> {in: 8..100},
				:unless 					=> :already_has_password?

	before_save :encrypt_password
	after_save :clear_password

	def already_has_password?
		!self.encrypted_password.blank?
	end

	def already_has_email?
		!self.email.blank?
	end

	def has_password?(submitted_password)
		self.encrypted_password == encrypt(submitted_password)
	end

	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
	end

	private
		def encrypt_password
			if password.present?
				self.salt = Digest::SHA2.hexdigest("#{Time.now.utc}--#{self.password}") if self.new_record?
				self.encrypted_password = encrypt(self.password)
			end
		end

		def encrypt(pass)
			Digest::SHA2.hexdigest("#{self.salt}--#{pass}")
		end

		def clear_password
			self.password = nil
		end
end