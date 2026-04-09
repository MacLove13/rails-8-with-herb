class HomeController < ApplicationController
  def index
    @jobs_count = SolidQueue::Job.count rescue 0
  end
end
