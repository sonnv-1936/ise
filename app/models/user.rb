class User < ApplicationRecord
  include FriendlyId
  friendly_id :name, use: :slugged

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :confirmable, :omniauthable, omniauth_providers: %i(google_oauth2)

  enum gender: %i(male female)
  enum type: {Admin: Admin.name, Manager: Manager.name,
    Staff: Staff.name, Student: Student.name}

  belongs_to :major, optional: true

  has_many :lead_events, class_name: Event.name, foreign_key: :leader_id
  has_many :user_enroll_events, dependent: :destroy
  has_many :enrolls, source: :event, through: :user_enroll_events
  has_many :requirements, ->{order verified: :desc}, foreign_key: :user_id,
    class_name: UserEventRequirement.name, dependent: :destroy
  has_many :event_requirements, source: :detail, through: :requirements
  has_one :avatar, as: :imageable, dependent: :destroy, class_name: Image.name

  accepts_nested_attributes_for :avatar, allow_destroy: true,
    reject_if: proc {|attributes| attributes["file"].blank?}

  validates :name, presence: true, length: {maximum: Settings.model.user.max_name_length,
    minimum: Settings.model.user.min_name_length},
    format: {with: Regexp.new(Settings.regex.only_word)}
  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :phone, numericality: true, presence: true,
    length: {maximum: Settings.model.user.phone_number.maximum,
      minimum: Settings.model.user.phone_number.minimum}
  validates :code, presence: true, uniqueness: true,
    format: {with: Regexp.new(Settings.regex.roll_number)}
  validates_presence_of :gender, :dob

  def find_enroll event, status = nil
    status ||= UserEnrollEvent.statuses.values.to_a
    user_enroll_events.find_by event_id: event, status: status
  end

  def check_enroll_status event
    find_enroll(event)&.status || Settings.model.user_enroll_event.status.unenroll
  end

  def enrolling
    user_enroll_events.find_by status: UserEnrollEvent.statuses.values[0]
  end
end
