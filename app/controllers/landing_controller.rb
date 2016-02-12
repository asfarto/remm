class LandingController < ApplicationController
  def index
    @time = File.open('last_deploy', &:readline)
  end
end
