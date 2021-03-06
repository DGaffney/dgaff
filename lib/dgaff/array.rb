class Array
  def to_i
    self.collect{|x| x.to_i}
  end

  def to_f
    self.collect{|x| x.to_f}
  end

  def frequencies
   new_val = {}
   self.each do |s|
     elem = s.to_s
     new_val[elem].nil? ? new_val[elem]=1 : new_val[elem]+=1
   end
   return new_val
  end

  def chunk(pieces=2)
    len = self.length
    return [] if len == 0
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end

  def repack
    set = []
    self.each do |slice|
      set<<slice
      yield set
    end
  end

  def centroid
    dimensions = self.flatten
    x_cent = (x_vals = 1.upto(dimensions.length).collect{|x| dimensions[x] if x.even?}.compact).sum/x_vals.length
    y_cent = (y_vals = 1.upto(dimensions.length).collect{|y| dimensions[y] if !y.even?}.compact).sum/y_vals.length
    return x_cent, y_cent
  end

  def area
    side_one = (self[0].to_f-self[2].to_f).abs
    side_two = (self[1].to_f-self[3].to_f).abs
    return side_one*side_two
  end

  def all_combinations(length_range=1..self.length)
    permutations = []
    length_range.max.downto(length_range.min) do |length|
      self.permutation(length).each do |perm|
        permutations << perm.sort if !permutations.include?(perm.sort)
      end
    end
    return permutations
  end

  def structs_to_hashes
    keys = (self.first.methods-Class.methods).collect{|x| x.to_s.gsub("=", "") if x.to_s.include?("=") && x.to_s!= "[]="}.compact
    hashed_set = []
    self.each do |struct|
      object = {}
      keys.collect{|k| object[k] = k.class == DateTime ? struct.send(k).to_time : struct.send(k)}
      hashed_set << object
    end
    return hashed_set
  end

  def sth
    structs_to_hashes
  end

  def moving_average(increment = 1)
    return self.average if increment == 1
    a = self.dup
    result = []
    while(!a.empty?)
      data = a.slice!(0,increment)
      result << data.average
    end
    result
  end  
  
  def ci_with_mean(conf_level=1.96)
    return [0,0,0] if self.empty?
    mean = self.average
    stdev = self.standard_deviation
    [mean-(conf_level*stdev)/Math.sqrt(self.length), mean, mean+(conf_level*stdev)/Math.sqrt(self.length)]
  end

  def self.model_sample(n, count)
    offsets = []
    while offsets.length < n
      offsets << rand(count)
    end
    return offsets
  end

  def median
    return nil if self.empty?
    self.sort!
    if self.length % 2 == 0
      (self[self.length / 2] + self[self.length/2 - 1]) / 2.0
    else
      self[self.length / 2]
    end
  end
  
  def sum
    return self.collect(&:to_f).inject(0){|acc,i|acc +i}
  end

  def average
    return self.sum/self.length.to_f
  end

  def sample_variance
    avg=self.average
    sum=self.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/self.length.to_f*sum)
  end

  def standard_deviation
    return 0 if self.empty?
    return Math.sqrt(self.sample_variance)
  end
  
  def standardize
    return self if self.uniq.length == 1
    stdev = self.standard_deviation
    mean = self.average
    self.collect do |val|
      (val-mean)/stdev
    end
  end

  def counts
    self.inject(Hash.new(0)) do |hash,element|
      hash[element] += 1
      hash
    end
  end

  def percentile(percentile=0.0)
    if percentile == 0.0
      return self.sort.first
    else
      classes = self.collect(&:class).uniq
      if ([Hash, Array]-classes==[Hash, Array]) && classes.length == 1
        return self ? self.sort[((self.length * percentile).ceil)-1] : nil rescue nil
      else
        return self[((self.length * percentile).ceil)-1]
      end
    end
  end

  def reverse_percentile(value=0.0)
    index_value = nil
    self.collect(&:to_f).sort.each do |val|
      index_value = val;break if value <= val
    end
    return (self.index(index_value)/self.length.to_f)
  end
  
  def mode
    freq = self.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    self.sort_by { |v| freq[v] }.last
  end
  
  def all_stats
    summary_statistics = {}
    summary_statistics[:min] = self.min
    summary_statistics[:first_quartile] = self.percentile(0.25)
    summary_statistics[:second_quartile] = self.percentile(0.5)
    summary_statistics[:third_quartile] = self.percentile(0.75)
    summary_statistics[:max] = self.max
    summary_statistics[:median] = self.median 
    summary_statistics[:mode] = self.mode
    summary_statistics[:mean] = self.average
    summary_statistics[:standard_deviation] = self.standard_deviation
    summary_statistics[:sum] = self.sum
    summary_statistics[:sample_variance] = self.sample_variance
    summary_statistics[:elbow] = self.elbow
    summary_statistics[:n] = self.length
    summary_statistics
  end
  
  def exclude?(elem)
    !self.include?(elem)
  end
  
  def normalize(min=0, max=1)
      current_min = self.min.to_f
      current_max = self.max.to_f
    self.map {|n| min + (n - current_min) * (max - min) / (current_max - current_min)}
  end
  
  def join_with_oxford_comma(delimiter=", ")
    string = ""
    if self.length == 1
      string = self.first
    elsif self.length == 2
      string = self.join(" and ")
    else
      self.each_with_index do |elem,i|
        if i == 0
          string+= elem.to_s
        elsif i == self.length-1
          string+="#{delimiter}and #{elem}"
        else
          string+="#{delimiter}#{elem}"
        end
      end
    end
    string
  end

  def accumulate
    sum = 0
    self.map{|x| sum += x}
  end
  
  def rolling_average
    averaged = []
    self.accumulate.each_with_index do |el, i|
      averaged << el/(i+1).to_f
    end
    averaged
  end

  def elbow
    elbow_cutoff
  end

  def elbow_cutoff
    frequencies = self.counts
    distances = {}
    frequencies.each_pair do |insider_score, count|
      translated_x = insider_score/frequencies.keys.max.to_f
      translated_y = 1-insider_score/frequencies.keys.max.to_f
      index = frequencies.keys.sort.index(insider_score)
      expected_x = index/frequencies.length.to_f
      expected_y = 1-index/frequencies.length.to_f
      distances[insider_score] = Math.sqrt((translated_x-expected_x)**2+(translated_y-expected_y)**2)
    end
    elbow = distances.sort_by{|k,v| v}.last
    return 0 if elbow.nil?
    return elbow.first
  end
  
  def pareto_cutoff
    #our world is a bit more unfair. 0.8 moved to 0.9.
    self.percentile(0.9)
  end
end
