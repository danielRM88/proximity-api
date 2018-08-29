# == Schema Information
#
# Table name: filters
#
#  id                    :bigint(8)        not null, primary key
#  chair_id              :bigint(8)        not null
#  x                     :json
#  y                     :json
#  P                     :json
#  F                     :json
#  V1                    :json
#  H                     :json
#  V2                    :json
#  adjustment_threshold  :float            default(10.0)
#  adjustment_count      :integer          default(0)
#  continuous_adjustment :boolean          default(FALSE)
#

class Filter < ActiveRecord::Base
  belongs_to :chair
  serialize :x
  serialize :y
  serialize :P
  serialize :F
  serialize :V1
  serialize :H
  serialize :V2

  PROCESS_NOISE_SCALING_FACTOR = 1000;

  def initialize x0 = nil, f = Matrix[[1.0]], p = Matrix[[10.0]], v1 = Matrix[[0.01]], h = Matrix[[1.0]], v2 = Matrix[[1.0]]
    super()
    self.x = x0
    self.F = f
    self.P = p
    self.V1 = v1
    self.H = h
    self.V2 = v2
  end

  def filter y
    if y.present? && y.class == Matrix

      if self.x.blank?
        self.x = Matrix[[y[0,0]]]
      end

      self.y = y
      e = self.y - self.H*self.x
      s = self.H*self.P*self.H.transpose + self.V2
      si = s.inverse
      k = (self.F*self.P*self.H.transpose)*si
      self.x = self.x + k*e
      self.P = self.F*self.P*self.F.transpose + self.V1 - k*self.H*self.P*self.F.transpose

      # CONTINUOUS ADJUSTMENT
      if self.continuous_adjustment
        eps = e.transpose*si*e;
        if eps[0,0] > self.adjustment_threshold #&& eps[0,0] < self.adjustment_threshold*2
          Rails.logger.info "EPS: #{eps[0,0]} - THRESHOLD: #{self.adjustment_threshold} - COUNT: #{self.adjustment_count}"
          self.V1 = self.V1*PROCESS_NOISE_SCALING_FACTOR
          self.adjustment_count += 1
        elsif self.adjustment_count > 0
          self.V1 = self.V1/PROCESS_NOISE_SCALING_FACTOR
          self.adjustment_count -= 1
        end
        Rails.logger.info "V1: #{self.V1[0,0]}"
      elsif self.adjustment_count > 0
        self.V1 = self.V1/PROCESS_NOISE_SCALING_FACTOR
        self.adjustment_count -= 1
      end
      # #####################

      self.save
    end

    return self.x
  end
end
