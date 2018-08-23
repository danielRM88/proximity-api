class KMeans
  attr_accessor :k
  attr_accessor :clusters

  ALGORITHM_NAME = "Online k-means"

  def initialize clusters = [0.0, 0.0]
    super()
    set_clusters clusters
  end

  def set_clusters clusters
    self.k = clusters.size
    self.clusters = []
    i = 0
    while i < self.k do
      self.clusters << {mean: clusters[i], n: 0}
      i+=1
    end
  end

  def algorithm_name
    return KMeans::ALGORITHM_NAME
  end

  def perform x
    assigned_cluster_index = nil
    min_distance = nil
    distance = 0
    self.clusters.each_with_index do |c, index|
      mu = c[:mean]
      distance = (mu-x).abs
      if (min_distance.present? && distance < min_distance) || min_distance.blank?
        min_distance = distance
        assigned_cluster_index = index
      end
    end

    mu = self.clusters[assigned_cluster_index][:mean]
    n = self.clusters[assigned_cluster_index][:n] + 1

    mu = mu + (1.0/n)*(x - mu)
    self.clusters[assigned_cluster_index] = {mean: mu, n: n}

    return assigned_cluster_index == 1
  end
end
