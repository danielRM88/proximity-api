require 'matrix'

class Matrix
  public :"[]=", :set_element, :set_component
end

class Array
  def cov(y)
    raise "Argument is not a Array class!"  unless y.class == Array
    raise "Self array is nil!"              if self.size == 0
    raise "Argument array size is invalid!" unless self.size == y.size

    # (arithmetic mean)
    mean_x = self.inject(0) { |s, a| s += a } / self.size.to_f
    mean_y = y.inject(0) { |s, a| s += a } / y.size.to_f
    # (covariance)
    cov = self.zip(y).inject(0) { |s, a| s += (a[0] - mean_x) * (a[1] - mean_y) }
    cov = cov / self.size
    # # (variance)
    # var_x = self.inject(0) { |s, a| s += (a - mean_x) ** 2 }
    # var_y = y.inject(0) { |s, a| s += (a - mean_y) ** 2 }
    # # (correlation coefficient)
    # r = cov / Math.sqrt(var_x)
    # r /= Math.sqrt(var_y)

    return cov.round(3)
  end
end