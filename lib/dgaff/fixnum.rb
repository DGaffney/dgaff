class Fixnum
  def delimited(delimiter=",")
    self.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
  end

  def percentage(round)
    self.to_f.round(round)*10.to_s+"%"
  end
  
  def rounded_with_suffix
    number_commafied = self.delimited.split(",")
    case number_commafied.length
    when 1
      return number_commafied.first
    when 2
      return number_commafied.first.length == 3 ? number_commafied.first+"K" : number_commafied.first+"."+number_commafied[1][0]+"K"
    when 3
      return number_commafied.first.length == 3 ? number_commafied.first+"M" : number_commafied.first+"."+number_commafied[1][0]+"M"
    when 4
      return number_commafied.first.length == 3 ? number_commafied.first+"B" : number_commafied.first+"."+number_commafied[1][0]+"B"
    when 5
      return number_commafied.first.length == 3 ? number_commafied.first+"T" : number_commafied.first+"."+number_commafied[1][0]+"T"
    end
  end

  def days
    return self*60*60*24
  end
  
  def day
    return days
  end

  def weeks
    return self*60*60*24*7
  end

  def week
    return weeks
  end

  def generalized_time_factor
    if self < 60
      #one second
      return 1
    elsif self < 3600
      #one minute
      return 60
    elsif self < 86400
      #one hour
      return 3600
    elsif self < 604800
      #one day
      return 86400
    elsif self < 11536000
      #one week
      return 604800
    else 
      #four weeks
      return 2419200
    end
  end
end