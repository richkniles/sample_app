class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user
  
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :at_reply_user_exists
  
  before_save :fill_in_in_reply_to

  default_scope order: 'microposts.created_at DESC'
  
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                            WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) or user_id= :user_id 
              or in_reply_to IN (#{followed_user_ids}) or in_reply_to = :user_id", 
              followed_user_ids: user.followed_user_ids, user_id: user)
  end
  
  private
    
    def at_reply_user_exists
      unless !content.starts_with?("@") || check_user
        errors.add(:content, "Post starting with @ must have existing user after @. #{get_reply_user} does not exist")
      end
    end
    
    def fill_in_in_reply_to
      if content.starts_with?("@")
        self.in_reply_to = User.where("LOWER(user_name) = ?", get_reply_user.downcase).first.id
      end
    end
     
    def get_reply_user
      md = /@[^ ]* /.match(content).to_s
      md[1..md.length-2]
    end
      
    def check_user
      User.where("LOWER(user_name) = ?", get_reply_user.downcase).count > 0
    end
end

