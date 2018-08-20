# == Schema Information
#
# Table name: filters
#
#  id       :bigint(8)        not null, primary key
#  chair_id :bigint(8)        not null
#  x        :json
#  y        :json
#  P        :json
#  F        :json
#  V1       :json
#  H        :json
#  V2       :json
#

require 'matrix'

class Filter < ActiveRecord::Base
  belongs_to :chair
  serialize :x
  serialize :y
  serialize :P
  serialize :F
  serialize :V1
  serialize :H
  serialize :V2

  def initialize x0 = Matrix[[0.0]], f = Matrix[[1.0]], p = Matrix[[1.0]], v1 = Matrix[[1.0]], h = Matrix[[1.0]], v2 = Matrix[[1.0]]
    super()
    self.x = x0
    self.F = f
    self.P = p
    self.V1 = v1
    self.H = h
    self.V2 = v2
  end

  def filter y
    self.y = y
    e = self.y - self.H*self.x
    s = self.H*self.P*self.H.transpose + self.V2
    si = s.inverse
    k = (self.F*self.P*self.H.transpose)*si
    self.x = self.x + k*e
    self.P = self.F*self.P*self.F.transpose + self.V1 - k*self.H*self.P*self.F.transpose

    self.save

    return self.x
  end
end
