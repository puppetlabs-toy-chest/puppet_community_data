class PullRequest

  attr_accessor :pull_request_num
  attr_accessor :pull_request_repo
  attr_accessor :pull_request_lifetime
  attr_accessor :pull_request_merge_status

  def initialize(num, repo, lifetime, merge_status)
    @pull_request_num = num
    @pull_request_repo = repo
    @pull_request_lifetime = lifetime
    @pull_request_merge_status = merge_status
  end
end
