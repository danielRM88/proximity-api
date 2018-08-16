# == Schema Information
#
# Table name: filters
#
#  id       :bigint(8)        not null, primary key
#  chair_id :bigint(8)        not null
#

class Filter < ActiveRecord::Base
  belongs_to :chair
end
