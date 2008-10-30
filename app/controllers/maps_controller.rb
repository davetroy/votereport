class MapsController < ApplicationController
  def activity
    @reports = Report.find(:all, :include => [:location], :conditions => ['created_at > ?', Time.now-4.hours])
    #@filters = ::Filter.find(:all, :include => [:reports],
    #                         :conditions => ['filters.state IS NOT NULL and reports.created_at > ?', Time.now-8.hour])
    @state_reports = {}
    @reports.each do |r|
      begin
        state = r.location.administrative_area
        @state_reports[state] = 0 if !@state_reports.include? state
        @state_reports[state] += 1 if !state.blank?
      rescue
        next
      end
    end
    @state_reports = scale_state_counts(@state_reports)
    @states = @state_reports.collect{|st| st[0]}.join('')
    @vals = @state_reports.collect{|st| st[1]}.join(',')
  end

  def wait_time
    @filters = ::Filter.find(:all, :include => [:reports], :conditions => ['filters.state IS NOT NULL'])
    @state_times = {}
    # collect all the times
    @filters.collect do |f|
      # init
      @state_times[f.state.to_sym] = [] if !@state_times.include?(f.state.to_sym)
      # add the wait times for each state
      f.reports.each do |r|
        @state_times[f.state.to_sym].push r.wait_time if r.wait_time
      end
    end
    # now average the wait times
    @state_times.each do |state, times|
      @state_times[state] = times.inject(0){|avg, time| avg += time.to_f/times.size.to_f}
    end
    @state_times = scale_state_counts(@state_times)
    @states = @state_times.collect{|st| st[0]}.join('')
    @vals = @state_times.collect{|st| st[1]}.join(',')
  end
  
  private
  
  # takes a hash table of the form {:NY => 52, :MD => 26} and scales the max to 100.0
  def scale_state_counts(state_count)
    # find the max time
    max_count = state_count.max{|a,b| a[1] <=> b[1]}[1]
    # scale times to max of 100
    state_count.each do |state, count|
      state_count[state] = 100.0*count.to_f/max_count.to_f
    end
    return state_count
  end

end
